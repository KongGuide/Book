local mysql = require "kong.plugins.kong-mysql-log.mysql"
local osdate = os.date
local inited = false
local MySqlLogHandler = {}

MySqlLogHandler.PRIORITY = 6
MySqlLogHandler.VERSION = "1.0.0"

local function log(premature, conf, message)
    if premature then
        return
    end
    
    if inited == false then
        mysql:init(conf)
        inited = true
    end
    
    mysql:connect()
    local result = mysql:insert(conf.tab_name, message)
    if(result ~= false) then
        mysql:set_keepalive()
    end
    
end

local function build_message(conf)
    
    return {
        app_name = conf.app_name,
        date_time = osdate("%Y-%m-%d %H:%M:%S"),
        remote_addr = kong.client.get_ip(),
        forwarded_ip = kong.client.get_forwarded_ip(),
        status = kong.response.get_status(),
        method = kong.request.get_method(),
        upstream_addr = ngx.var.upstream_addr,
        upstream_response_time = ngx.var.upstream_response_time,
        http_host = kong.request.get_host(),
        query_string = kong.request.get_raw_query(),
        uri = kong.request.get_path(),
        user_agent = kong.request.get_header("User-Agent"),
        request_time = ngx.var.request_time,
        machine = ngx.var.hostname,
        in_bytes = ngx.var.request_length,
        out_bytes = ngx.var.bytes_sent,
        --referer = ngx.var.referer,
        --ssl = ngx.var.ssl_protocol,
        
    }
    
end

function MySqlLogHandler:log(conf)
    local message = build_message(conf)
    local ok, err = ngx.timer.at(0, log, conf, message)
    if not ok then
        kong.log.err("[kong-mysql-log] failed to create timer: ", err)
    end
end

return MySqlLogHandler
