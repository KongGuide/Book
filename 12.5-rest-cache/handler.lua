local _plugin = require "kong.plugins.base_plugin":extend()
local _redis = require 'kong.plugins.rest-cache.redis'
local _encoder = require 'kong.plugins.rest-cache.encoder'
--传输编码
local HEADER_Transfer_Encoding = "transfer-encoding"
--数据类型json
local HEADER_Application_Json = "application/json"
--以秒为单位用响应头来设置响应缓存时间
local HEADER_Accel_Expires = "X-Accel-Expires"
--内容类型
local HEADER_Content_Type = "Content-Type"
--REST Cache命中标识
local HEADER_X_Rest_Cache = "x-rest-cache"
--连接Header头
local HEADER_Connection = "connection"
--MD5
local md5 = ngx.md5

function _plugin:new()
    _plugin.super.new(self, "rest-cache")
end
--构建缓存key
local function generate_cache_key()
    local cache_key =
    kong.request.get_host() .. ':' ..
    kong.request.get_method() .. ':' ..
    kong.request.get_path_with_query()
    return md5(cache_key)
end
--对数据进行编码序列化，异步写入远程redis
local function async_write_cache(config, cache_key, body, headers, status)
    ngx.timer.at(0, function(premature)
        local redis = _redis:new()
        redis:init(config)
        local cache_value = _encoder.encode(status, body, headers)
        redis:set(cache_key, cache_value, config.cache_ttl)
    end)
end

function _plugin:access(config)
    _plugin.super.access(self)
    
    local method = kong.request.get_method()
    if method ~= "GET" then
        return
    end
    
    local redis = _redis:new()
    redis:init(config)
    --生成缓存key
    local cache_key = generate_cache_key()
    --查询redis
    local cached_value, err = redis:get(cache_key)
    if cached_value and cached_value ~= ngx.null then
        --将命中的数据进行解码反序列化
        local response = _encoder.decode(cached_value)
        kong.response.set_header("X-REST-Cache", "Hit")
        if response.headers then
            for header, value in pairs(response.headers) do
                kong.response.set_header(header, value)
            end
        end
        kong.response.exit(200, response.content)
        return
    else
        kong.response.set_header("X-REST-Cache", "Miss")
        ngx.ctx.response_cache = {cache_key = cache_key}
    end
    
end

function _plugin:body_filter(config)
    _plugin.super.body_filter(self)
    
    local ctx = ngx.ctx.response_cache
    if not ctx then
        return
    end
    --如果上游服务器指定了返回过期时间(秒)，将覆盖配置中的标准的过期时间
    local cache_ttl = kong.service.response.get_header(HEADER_Accel_Expires)
    if cache_ttl then
        config.cache_ttl = cache_ttl
    end
    
    local chunk = ngx.arg[1]
    local eof = ngx.arg[2]
    --如果返回数据较大，直到接收到完整数据
    local res_body = ctx and ctx.res_body or ""
    res_body = res_body .. (chunk or "")
    ctx.res_body = res_body
    
    local status = kong.response.get_status()
    local content_type = kong.response.get_header(HEADER_Content_Type)
    --将返回的数据异步写入redis，条件必须返回状态为200且为json格式
    if eof and status == 200 and content_type and content_type == HEADER_Application_Json then
        local headers = kong.response.get_headers()
        headers[HEADER_Connection] = nil
        headers[HEADER_X_Rest_Cache] = nil
        headers[HEADER_Transfer_Encoding] = nil
        async_write_cache(config, ctx.cache_key, ctx.res_body, headers, status)
    end
    
end

_plugin.PRIORITY = 1001
_plugin.VERSION = '1.0.0'
return _plugin
