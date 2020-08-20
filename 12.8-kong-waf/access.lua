local iputils = require "resty.iputils"
local FORBIDDEN = 403
local cache = {}
local kong = kong

local rulematch = ngx.re.find
local unescape = ngx.unescape_uri
local fmt = string.format


local inited
local version = 0
local all_rules = {}

local USERAGENT_RULE = "useragent.rule"
local WHITEURL_RULE = "whiteurl.rule"
local COOKIE_RULE = "cookie.rule"
local ARGS_RULE = "args.rule"
local POST_RULE = "post.rule"
local URL_RULE = "url.rule"
--CIDR缓存
local function cidr_cache(cidr_tab)
    local cidr_tab_len = #cidr_tab
    local parsed_cidrs = kong.table.new(cidr_tab_len, 0)
    for i = 1, cidr_tab_len do
        local cidr = cidr_tab[i]
        local parsed_cidr = cache[cidr]
        if parsed_cidr then
            parsed_cidrs[i] = parsed_cidr
        else
            local lower, upper = iputils.parse_cidr(cidr)
            cache[cidr] = {lower, upper}
            parsed_cidrs[i] = cache[cidr]
        end
    end
    return parsed_cidrs
end

--获得真实的客户端IP
local function get_client_ip()
    local CLIENT_IP = ngx.req.get_headers()["X_real_ip"]
    if CLIENT_IP == nil then
        CLIENT_IP = ngx.req.get_headers()["X_Forwarded_For"]
    end
    if CLIENT_IP == nil then
        CLIENT_IP = ngx.var.remote_addr
    end
    if CLIENT_IP == nil then
        CLIENT_IP = "unknown"
    end
    return CLIENT_IP
end

--取得客户端 user agent
local function get_user_agent()
    local USER_AGENT = ngx.var.http_user_agent
    if USER_AGENT == nil then
        USER_AGENT = "unknown"
    end
    return USER_AGENT
end

--从wafconf目录取得对应文件的所有WAF规则内容
local function get_rule(rulefilename)
    local io = require 'io'
    local RULE_PATH = "/usr/local/share/lua/5.1/kong/plugins/kong-waf/wafconf"
    local RULE_FILE = io.open(RULE_PATH..'/'..rulefilename, "r")
    if RULE_FILE == nil then
        return
    end
    local RULE_TABLE = {}
    for line in RULE_FILE:lines() do
        table.insert(RULE_TABLE, line)
    end
    RULE_FILE:close()
    return(RULE_TABLE)
end

--记录WAF日志信息
local function log_record(method, url, data, ruletag, conf)
    local cjson = require("cjson")
    local io = require 'io'
    local LOG_PATH = conf.log_dir
    local CLIENT_IP = get_client_ip()
    local USER_AGENT = get_user_agent()
    local SERVER_NAME = ngx.var.server_name
    local LOCAL_TIME = ngx.localtime()
    local log_json_obj = {
        client_ip = CLIENT_IP,
        local_time = LOCAL_TIME,
        server_name = SERVER_NAME,
        user_agent = USER_AGENT,
        attack_method = method,
        req_url = url,
        req_data = data,
        rule_tag = ruletag,
    }
    local LOG_LINE = cjson.encode(log_json_obj)
    local LOG_NAME = LOG_PATH..'/kong_waf' .. "_"..ngx.today() .. ".log"
    local file = io.open(LOG_NAME, "a")
    if file == nil then
        return
    end
    file:write(LOG_LINE.."\n")
    file:flush()
    file:close()
end

--被WAF拦截后，返回给客户端的文件
local function waf_output(conf)
    if conf.waf_redirect then
        ngx.redirect(conf.waf_redirect_url, 301)
    else
        ngx.header.content_type = "text/html"
        --local binary_remote_addr = ngx.var.binary_remote_addr
        ngx.status = ngx.HTTP_FORBIDDEN
        local config_output_html = [[
            <html xmlns="http://www.w3.org/1999/xhtml"><head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
            <title>网站防火墙</title>
            <style>
            p {
                line-height:20px;
            }
            ul{ list-style-type:none;}
            li{ list-style-type:none;}
            </style>
            </head>
            <body style=" padding:0; margin:0; font:14px/1.5 Microsoft Yahei, 宋体,sans-serif; color:#555;">
            <div style="margin: 0 auto; width:1000px; padding-top:70px; overflow:hidden;">
             已拦截IP为: %s 的请求，请求含有危险非法内容，可能存在攻击行为！
            </div>
            </body></html>
        ]] 
        ngx.say(fmt(config_output_html, get_client_ip()))
        ngx.exit(ngx.status)
    end
end
--IP规则检查
local function ip_check(conf)
    local block = false
    local binary_remote_addr = ngx.var.binary_remote_addr
    
    if not binary_remote_addr then
        return kong.response.exit(FORBIDDEN, {message = "Cannot identify the client IP address, unix domain sockets are not supported."})
    end
    --IP黑名单检查
    if conf.blacklist and #conf.blacklist > 0 then
        block = iputils.binip_in_cidrs(binary_remote_addr, cidr_cache(conf.blacklist))
    end
    --IP白名单检查
    if conf.whitelist and #conf.whitelist > 0 then
        block = not iputils.binip_in_cidrs(binary_remote_addr, cidr_cache(conf.whitelist))
    end
    
    if block then
        return kong.response.exit(FORBIDDEN, {message = "Your IP address is not allowed"})
    end
end

--白名单规则检查
local function white_url_check(conf)
    local URL_WHITE_RULES = all_rules[WHITEURL_RULE]
    local REQ_URI = ngx.var.request_uri
    if URL_WHITE_RULES ~= nil then
        for _, rule in pairs(URL_WHITE_RULES) do
            if rule ~= "" and rulematch(REQ_URI, rule, "jo") then
                return true
            end
        end
    end
end

--cookie规则检查
local function cookie_attack_check(conf)
    local COOKIE_RULES = all_rules[COOKIE_RULE]
    local USER_COOKIE = ngx.var.http_cookie
    if USER_COOKIE ~= nil then
        for _, rule in pairs(COOKIE_RULES) do
            if rule ~= "" and rulematch(USER_COOKIE, rule, "jo") then
                log_record('Deny_Cookie', ngx.var.request_uri, "-", rule, conf)
                waf_output(conf)
                return true
            end
        end
    end
    return false
end

--url规则检查
local function url_attack_check(conf)
    local URL_RULES = all_rules[URL_RULE]
    local REQ_URI = ngx.var.request_uri
    for _, rule in pairs(URL_RULES) do
        if rule ~= "" and rulematch(REQ_URI, rule, "jo") then
            log_record('Deny_URL', REQ_URI, "-", rule, conf)
            waf_output(conf)
            return true
        end
    end
    return false
end

--url参数规则检查
local function url_args_attack_check(conf)
    local ARGS_RULES = all_rules[ARGS_RULE]
    for _, rule in pairs(ARGS_RULES) do
        local REQ_ARGS = ngx.req.get_uri_args()
        for key, val in pairs(REQ_ARGS) do
            if type(val) == 'table' then
                local ARGS_DATA = table.concat(val, " ")
            else
                local ARGS_DATA = val
            end
            if ARGS_DATA and type(ARGS_DATA) ~= "boolean" and rule ~= "" and rulematch(unescape(ARGS_DATA), rule, "jo") then
                log_record('Deny_URL_Args', ngx.var.request_uri, "-", rule, conf)
                waf_output(conf)
                return true
            end
        end
    end
    return false
end

--user agent规则检查
local function user_agent_attack_check(conf)
    local USER_AGENT_RULES = all_rules[USERAGENT_RULE]
    local USER_AGENT = ngx.var.http_user_agent
    if USER_AGENT ~= nil then
        for _, rule in pairs(USER_AGENT_RULES) do
            if rule ~= "" and rulematch(USER_AGENT, rule, "jo") then
                log_record('Deny_USER_AGENT', ngx.var.request_uri, "-", rule, conf)
                waf_output(conf)
                return true
            end
        end
    end
    return false
end

--post数据规则检查
local function post_attack_check(conf)
    ngx.req.read_body()
    local POST_RULES = all_rules[POST_RULE]
    for _, rule in pairs(POST_RULES) do
        local POST_ARGS = ngx.req.get_post_args() or {}
        for k, v in pairs(POST_ARGS) do
            local post_data = ""
            if type(v) == "table" then
                post_data = table.concat(v, ", ")
            elseif type(v) == "boolean" then
                post_data = k
            else
                post_data = v
            end
            
            if rule ~= "" and rulematch(post_data, rule, "jo") then
                log_record('Post_Attack', post_data, "-", rule, conf)
                waf_output(conf)
                return true
            end
        end
    end
    return false
end

local _M = {}

function _M.check_init(conf)
    --初使化规则数据
    if inited or conf.version > version then
        all_rules[USERAGENT_RULE] = get_rule(USERAGENT_RULE)
        all_rules[COOKIE_RULE] = get_rule(COOKIE_RULE)
        all_rules[WHITEURL_RULE] = get_rule(WHITEURL_RULE)
        all_rules[URL_RULE] = get_rule(URL_RULE)
        all_rules[ARGS_RULE] = get_rule(ARGS_RULE)
        all_rules[POST_RULE] = get_rule(POST_RULE)
        inited = true
        version = conf.version
    end
    
end
--运行所有WAF规则检查
function _M.execute(conf)
    if ip_check(conf) then
    elseif conf.user_agent_check and user_agent_attack_check(conf) then
    elseif conf.cookie_check and cookie_attack_check(conf) then
    elseif conf.white_url_check and white_url_check(conf) then
    elseif conf.url_check and url_attack_check(conf) then
    elseif conf.url_args_check and url_args_attack_check(conf) then
    elseif conf.post_check and post_attack_check(conf) then
    else
        return
    end
end

return _M
