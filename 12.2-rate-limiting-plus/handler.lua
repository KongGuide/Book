local pairs = pairs
local osdate = os.date
local fmt = string.format
local tostring = tostring
local mathmax = math.max
local tonumber = tonumber
local RATELIMIT_DATE = "X-RateLimit-Date"
--速率限制数量
local RATELIMIT_LIMIT = "X-RateLimit-Limit"
local timestamp = require "kong.tools.timestamp"
local BasePlugin = require "kong.plugins.base_plugin"
--速率限制剩余数量
local RATELIMIT_REMAINING = "X-RateLimit-Remaining"
local policies = require "kong.plugins.rate-limiting-plus.policies"
local http_client = require 'kong.plugins.rate-limiting-plus.http_client'
local plugin = BasePlugin:extend()
plugin.PRIORITY = 901
plugin.VERSION = "0.1.0"

local function cache_key(key)
    return fmt("LIMIT_PLUS_%s", key)
end

--取得当前限制的使用量
local function get_usage(conf, identifier, current_timestamp, limits)
    local usage = {}
    local stop
    
    for name, limit in pairs(limits) do
        if(limit >= 0) then
            local current_usage, err = policies[conf.policy].usage(conf, identifier, current_timestamp, name)
            if err then
                return nil, nil, err
            end
            
            --取得剩余数量
            local remaining = limit - current_usage
            
            --返回使用量情况
            usage[name] = {
                limit = limit,
                remaining = remaining
            }
            --如果使用剩余次数用完，记录限制的时间单位在那一级别天时分秒
            if remaining <= 0 then
                stop = name
            end
        end
        
    end
    
    return usage, stop
end

function plugin:new()
    plugin.super.new(self, "beisen-paas-rate-limiting")
end

function plugin:access(conf)
    plugin.super.access(self)
    
    local identifier_limits = {}
    local current_timestamp = timestamp.get_utc()
    local policy = conf.policy
    local fault_tolerant = conf.fault_tolerant
    
    --从请求header中读取企业ID
    local company_id = kong.request.get_header(conf.header_name)
    --如果未读取到企业ID
    if company_id == nil then
        return kong.response.exit(400, "company id is empty")
    --如果读取的企业ID不是5位或不是数值类型
    elseif #company_id ~= 5 or tonumber(company_id) == nil then
        return kong.response.exit(400, "company id error")
    end

    local host = kong.request.get_host()
    local method = kong.request.get_method()
    local path = kong.request.get_path()
    
    --构建缓存key
    local cache_key_str = cache_key(fmt("%s_%s_%s_%s", host, path, method,company_id))
    --构建查询限流服务器数据来源的请求参数
    local query = fmt("domain=%s&path=%s&method=%s&companyId=%s", host, path, method,company_id)
    --查询并缓存在mlcache
    local limit_value_json, err = kong.cache:get(cache_key_str, {}, http_client.query_from_web_try, conf, query)

    if err then
        kong.log.err("internal-error: ", err)
        return kong.response.exit(400, "request error")
    end
    
    if limit_value_json == nil or limit_value_json == ngx.null then
        return kong.response.exit(400, "result is null internal-error")
    end

    local identifier_1 = (limit_value_json["rateLimits"][1].key)
    local identifier_2 = (limit_value_json["rateLimits"][2].key)
    local identifier_3 = (limit_value_json["rateLimits"][3].key)
    
    local limits_level_1 = {
        second = limit_value_json["rateLimits"][1].second,
        minute = limit_value_json["rateLimits"][1].minute,
        hour = limit_value_json["rateLimits"][1].hour,
        day = limit_value_json["rateLimits"][1].day,
    }
    
    local limits_level_2 = {
        second = limit_value_json["rateLimits"][2].second,
        minute = limit_value_json["rateLimits"][2].minute,
        hour = limit_value_json["rateLimits"][2].hour,
        day = limit_value_json["rateLimits"][2].day,
    }

    local limits_level_3 = {
        second = limit_value_json["rateLimits"][3].second,
        minute = limit_value_json["rateLimits"][3].minute,
        hour = limit_value_json["rateLimits"][3].hour,
        day = limit_value_json["rateLimits"][3].day,
    }
    
    --构建3层，速率限制的基础数据
    identifier_limits[identifier_1] = limits_level_1
    identifier_limits[identifier_2] = limits_level_2
    identifier_limits[identifier_3] = limits_level_3
    
    for identifier, limits in pairs(identifier_limits) do
        --取得当前使用量
        local usage, stop, err = get_usage(conf, identifier, current_timestamp, limits)
        if err then
            if fault_tolerant then
                kong.log.err("failed to get usage: ", tostring(err))
            else
                return kong.response.exit(500, err)
            end
        end
        
        if usage then
            if conf.debug_mode then
                for k, v in pairs(usage) do
                    --设置客户端返回的header信息
                    kong.response.set_header(RATELIMIT_LIMIT .. "-" .. k, v.limit)
                    kong.response.set_header(RATELIMIT_DATE, osdate("%Y-%m-%d %H:%M:%S"))
                    kong.response.set_header(RATELIMIT_REMAINING .. "-" .. k, mathmax(0, (stop == nil or stop == k) and v.remaining - 1 or v.remaining))
                end
            end
            --如果达到速率所限制的使用量，返回超出限制信息
            if stop then
                return kong.response.exit(429, "API rate limit exceeded")
            end
        end
        
    end
    --未超出使用量，增加请求统计信息
    for identifier, limits in pairs(identifier_limits) do
        policies[policy].increment(conf, limits, identifier, current_timestamp, 1)
    end
    
end

return plugin

