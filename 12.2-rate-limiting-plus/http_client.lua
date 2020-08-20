local cjson = require "cjson.safe"
local http = require "resty.http"

local _M = {}


local function query_from_web(http_conf, query)
    local httpc = http.new()
    httpc:connect(http_conf.limit_data_host, http_conf.limit_data_port)
    httpc:set_timeout(http_conf.timeout)
    local res, err = httpc:request {
        method = "GET",
        path = http_conf.limit_data_url .. "?" .. query
    }
    return httpc, res, err
end

function _M.query_from_web_try(http_conf, query)
    
    local httpc, res, err
    for i = 1, http_conf.http_try_number, 1 do
        httpc, res, err = query_from_web(http_conf, query)
        if not err and res.status == 200 then
            break
        else
            kong.log.err("try request error:" .. http_conf.limit_data_url .. " number: (" .. i .. "/" .. http_conf.http_try_number .. ")", (res and res.status or nil), " ", err)
        end
    end
    if err or res.status ~= 200 then
        ngx.log(ngx.ERR, "request error: ", err or "nil" .. "/" .. res.status)
        return nil, err, http_conf.key_ttl
    end
    
    local json = cjson.decode(res:read_body())
    local ok, err = httpc:set_keepalive(http_conf.idle_timeout, http_conf.pool_size)
    if not ok then
        ngx.log(ngx.ERR, "could not keepalive connection: ", err)
        return nil, err, http_conf.key_ttl
    end
    
    return json, err, json["ttl"]
end

return _M

