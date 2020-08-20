--当前数据版本
local data_version = 0
--数据缓存词典
local data_dict = {}
local cookie = require "resty.cookie"
local plugin = require("kong.plugins.base_plugin"):extend()

function plugin:new()
    plugin.super.new(self, "smart-route")
end
--以“:”号，将数据进行拆分，返回key/value
local function iter(config_array)
    return function(config_array, i, previous_name, previous_value)
        i = i + 1
        local current_pair = config_array[i]
        if current_pair == nil then
            return nil
        end
        
        local current_name, current_value = current_pair:match("^([^:]+):*(.-)$")
        if current_value == "" then
            current_value = nil
        end
        
        return i, current_name, current_value
    end, config_array, 0
end
--初使化数据
local function init_data(config_array)
    for _, name, value in iter(config_array) do
        data_dict[name] = false
        if(value == "true") then
            data_dict[name] = true
        end
    end
end

function plugin:access(conf)
    plugin.super.access(self)
    --判断插件数据版本是否发生变化，如变化需要重新初使化
    if(conf.data_version > data_version) then
        data_dict = {}
        init_data(conf.identify_values)
        data_version = conf.data_version
    end
    
    local identify_value = nil
    if conf.identify_source == "header" then
        --读取指定的header名称数据
        identify_value = kong.request.get_header(conf.header_key_name)
    elseif conf.identify_source == "query" then
        --读取指定的querystring名称数据
        identify_value = kong.request.get_query_arg(conf.query_key_name)
    elseif conf.identify_source == "cookie" then
        --读取指定的cookie名称数据
        identify_value = cookie:new():get(conf.cookie_key_name)
    end
    --如果读取和值包含在配置中，则路由到新的V2版本上游服务器
    if identify_value ~= nil and data_dict[identify_value] ~= nil and data_dict[identify_value] == true then
        --更改upstream信息
        kong.service.set_upstream(conf.upstream_service_name)
    end
end
--插件优先级
plugin.PRIORITY = 12

return plugin
