--当前数据版本
local data_version = 0
--用户下载速度的数据缓存词典
local user_limit_data_dict = {}
local plugin = require("kong.plugins.base_plugin"):extend()

function plugin:new()
    plugin.super.new(self, "download-rate-limiting")
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
        user_limit_data_dict[name] = value
    end
end

function plugin:access(conf)
    plugin.super.access(self)
    --判断插件数据版本是否发生变化，如变化需要重新初使化
    if(conf.data_version > data_version) then
        user_limit_data_dict = {}
        init_data(conf.user_limit_values)
        data_version = conf.data_version
    end
    --读取指定的header名称数据，从中取出user id
    local user_id = kong.request.get_header(conf.user_id_header_name)
    --判断是否取出user id且是否存在于配置中
    if user_id and user_limit_data_dict[user_id] then
        --存在于配置中，根据配置限制下载速度
        ngx.var.limit_rate = user_limit_data_dict[user_id]
    else
        --不存在于配置中，使用默认配置值限制下载速度
        ngx.var.limit_rate = conf.default_rate_limiting
    end
    
end
--插件优先级
plugin.PRIORITY = 10

return plugin
