local plugin = require("kong.plugins.base_plugin"):extend()

function plugin:new()
    plugin.super.new(self, "bridg-data-center")
end

function plugin:access(plugin_conf)
    plugin.super.access(self)
    --取得当前使用的上游服务器名称
    local upstream_name = kong.router.get_service().host
    --判断当前负载均衡器中是否是健康状态
    local health = kong.upstream.get_balancer_health(upstream_name).health
    --如果当前负载均衡器为不健康，转到另外一个数据中心
    if(health and health ~= "HEALTHY") then
        local dc_upstream_name = upstream_name .. "_" .. plugin_conf.failover_data_center
        kong.service.set_upstream(dc_upstream_name)
    end
    
end

plugin.PRIORITY = 1000

return plugin
