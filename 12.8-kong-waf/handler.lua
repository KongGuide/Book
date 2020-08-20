local access = require "kong.plugins.kong-waf.access"

local plugin = {}
plugin.PRIORITY = 2000
plugin.VERSION = "1.0.1"

function plugin:new()
    --IP to LBS
    plugin.super.new(self, "kong-waf")
end

function plugin:access(conf)
    --是否开启waf插件功能
    if not conf.waf_enable then
        return
    end
    access.check_init(conf)
    access.execute(conf)
end

return plugin
