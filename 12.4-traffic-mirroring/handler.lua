local plugin = require("kong.plugins.base_plugin"):extend()
local http = require "resty.http"
local cjson = require "cjson.safe"

function plugin:new()
    plugin.super.new(self, "traffic-mirroring")
end
--发送数据到后端镜像服务器
local function send_data_mirror(premature, conf, request)
    local httpc = http.new()
    httpc:connect(conf.traffic_mirroring_host, conf.traffic_mirroring_port)
    httpc:set_timeout(conf.connect_timeout)
    local res, err = httpc:request {
        path = request.path,
        method = request.method,
        body = request.body,
        headers = request.headers,
        query = request.query
    }
    
    if err or res == nil then
        kong.log.err("request error: ", res.status)
        return
    end
    local content = res:read_body()
    kong.log.warn("received: ", content)
    --设置keepalive长链接
    local ok, err = httpc:set_keepalive(conf.connect_pool_idle_timeout, conf.connect_pool_size)
    if not ok then
        kong.log.err("could not keepalive connection: ", err)
    end
end

function plugin:access(conf)
    plugin.super.access(self)
    local request = {
        path = kong.request.get_path(),
        method = kong.request.get_method(),
        body = kong.request.get_raw_body(),
        headers = kong.request.get_headers(),
    query = kong.request.get_raw_query()}
    --异步发送到镜像服务器
    local ok, err = ngx.timer.at(0, send_data_mirror, conf, request)
    if not ok then
        kong.log.err("create timer failed", err)
    end
end

plugin.PRIORITY = 100
return plugin
