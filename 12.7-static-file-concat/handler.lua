local plugin = require("kong.plugins.base_plugin"):extend()
local pl_stringx = require "pl.stringx"
local http = require "resty.http"
local md5 = ngx.md5
local char = string.char
local gsub = string.sub



function plugin:new()
    plugin.super.new(self, "static-file-concat")
end
--从远程服务器获取单个静态文件资源数据
local function query_from_server(path, conf)
    local httpc = http.new()
    httpc:connect(conf.static_file_host, conf.static_file_port)
    httpc:set_timeout(conf.connect_timeout)
    local res, err = httpc:request {
        path = "/" .. path,
        method = "GET"
    }
    if err or res.status ~= 200 then
        kong.log.err("request error: ", res.status, path)
        return "", err
    end
    
    local data = res:read_body()
    --设置keepalive长链接
    local ok, err = httpc:set_keepalive(conf.connect_pool_idle_timeout, conf.connect_pool_size)
    if not ok then
        kong.log.err("could not keepalive connection: ", err)
        return "", err
    end
    return data, nil
end
--将多个静态资源文件内容合并
local function generate_content(file_parts, conf)
    local content = ""
    file_parts[1] = pl_stringx.lstrip(file_parts[1], "?")
    for _, file in ipairs(file_parts) do
        local file_data, err = query_from_server(file, conf)
        if err then
            kong.log.err("internal-error: ", err)
            return nil, err, 10
        end
        content = content.. conf.concat_delimiter .. file_data
    end
    --判断合并的内容大小是否超过限制
    if #content > conf.concat_max_files_size then
        kong.log.err("[concat_max_files_size] exceeded limit: ", conf.concat_max_files_size)
        return nil, "File size exceeded limit:" .. conf.concat_max_files_size, 10
    end
    
	 if pl_stringx.endswith(file_parts[1], 'js') then
        kong.response.set_header("content-type", "text/javascript")
    else
        kong.response.set_header("content-type", "text/css")
    end

    return content, nil, conf.key_ttl
end

local function url_decode(str)
  str = gsub(str, '%%(%x%x)', function(h) return char(tonumber(h, 16)) end)
  return str
end

function plugin:access(conf)
    plugin.super.access(self)
    local query = url_decode(kong.request.get_raw_query())
    local is_double_question = pl_stringx.startswith(query, '?')
    
    if not is_double_question then
        return
    end
    --将请求的文件进行拆分，判断是否超过限制
    local file_parts = pl_stringx.split(query, ';')
    if file_parts and #file_parts > conf.concat_max_files_number then
        kong.log.err("[concat_max_files_number] exceeded : ", conf.concat_max_files_number)
        return kong.response.exit(400, "File number exceeded limit")
    end
    --对请求的多个静态资源文件列表进行哈希
    local uri_md5 = md5(query)
    local cache_key = "concat_" .. uri_md5
    print("cache_key:" .. cache_key)
    --从缓存中查找是否已经是合并后的数据，如是直接返回，反之生成合并后的内容
    -- kong.cache基于lua-resty-mlcache多级缓存、锁机制，确保原子回调
    local content, err = kong.cache:get(cache_key, {ttl = 0}, generate_content, file_parts, conf)
    
    if err then
        kong.log.err("internal-error: ", err)
        return kong.response.exit(500, "Internal error")
    end
    
    if content == nil then
        kong.log.err("internal-error: static content is null")
        return kong.response.exit(500, "Cache error")
    end
    
    return kong.response.exit(200, content)
    
end

plugin.PRIORITY = 1000
return plugin
