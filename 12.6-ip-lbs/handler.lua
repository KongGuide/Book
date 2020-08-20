local plugin = require("kong.plugins.base_plugin"):extend()
local pl_stringx = require "pl.stringx"
local http = require "resty.http"
local cjson = require "cjson.safe"

function plugin:new()
    --IP to LBS
    plugin.super.new(self, "ip-lbs")
end
--取得真实的客户端IP
function get_ip()
    local ip = kong.request.get_header("X-Forwarded-For")
    if ip ~= nil then
        local ips = pl_stringx.split(ip, ',')
        return nips[1]
    end
    ip = kong.request.get_header("X-Real-IP");
    if ip ~= nil then
        return ip
    end
    return ngx.var.remote_addr
end
--查询后台服务，根据传入的IP返回地址位置信息
local function query_from_web(ip, conf)
    local httpc = http.new()
    httpc:connect(conf.lbs_service_host, conf.lbs_service_port)
    httpc:set_timeout(conf.connect_timeout)
    local res, err = httpc:request {
        path = conf.lbs_service_url,
        query = "ip=" .. ip,
        method = "GET"
    }
    if err or res == nil then
        kong.log.err("request error: ", res.status)
        return nil, err, 10
    end
    local json = cjson.decode(res:read_body())
    local ok, err = httpc:set_keepalive(conf.connect_pool_idle_timeout, conf.connect_pool_size)
    if not ok then
        kong.log.err("could not keepalive connection: ", err)
        return nil, err, 10
    end
    return json, err, conf.key_ttl
end

function plugin:access(conf)
    plugin.super.access(self)
    local ip = get_ip()
    local cache_key = "lbs_" .. ip
    local json, err = kong.cache:get(cache_key, {ttl = 0}, query_from_web, ip, conf)
    
    if err then
        kong.log.err("internal-error: ", err)
        return kong.response.exit(500, "internal error")
    end
    
    if json == nil then
        kong.log.err("internal-error: cache json is null")
        return kong.response.exit(500, "cache error")
    end
    --在请求中的添加地理位置信息Header头
    kong.service.request.add_header("X-IP", ip)
    kong.service.request.add_header("X-Location", json["location"])
    kong.service.request.add_header("X-Longitude", json["longitude"])
    kong.service.request.add_header("X-Latitude", json["latitude"])
    kong.service.request.add_header("X-Radius", json["radius"])
    kong.service.request.add_header("X-Confidence", json["confidence"])
end

plugin.PRIORITY = 100
return plugin
