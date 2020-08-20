local mysql = require "resty.mysql"

local _M = {}

function _M:init(config)
    
    _M.host = config.host
    _M.port = config.port
    _M.database = config.database
    _M.user = config.user
    _M.password = config.password
    _M.charset = config.charset
    _M.timeout = config.timeout
    _M.max_packet_size = config.max_packet_size
    _M.max_idle_timeout = config.max_idle_timeout
    _M.pool_size = config.pool_size
    
    setmetatable(config, self)
    self.__index = self
end

function _M:connect()
    local db, err = mysql:new()
    if not db then
        kong.log.err("failed to mysql: ", err)
        return nil
    end
    
    db:set_timeout(self.timeout)
    
    local ok, err, err_code, sql_state = db:connect {
        host = self.host,
        port = self.port,
        database = self.database,
        user = self.user,
        password = self.password,
        max_packet_size = self.max_packet_size,
    }
    if not ok then
        kong.log.err("failed to connect: ", err, ": ", err_code, " ", sql_state)
        return nil
    end
    
    local ok, err = db:get_reused_times()
    if (not ok or ok == 0) and self.charset then
        db:query('SET NAMES ' .. self.charset)
    end
    
    self.db = db
    return true
end

function _M:set_keepalive()
    local ok, err = self.db:set_keepalive(self.max_idle_timeout, self.pool_size)
    if not ok then
        kong.log.err("failed to set_keepalive: ", err)
        return nil
    end
    return true
end

function _M:query(sql, rows)
    local res, err, errno, sql_state = self.db:query(sql, rows)
    if not res then
        kong.log.err("bad count result: ", err, ": ", errno, ": ", sql_state, " sql:", sql)
        return nil
    end
    return res
end

function _M:count(tb_name, where, sql)
    local count = 0
    if not sql then
        where = where or '1=1'
    end
    local sql = string.format("SELECT COUNT(1) AS NUM FROM %s WHERE %s", tb_name, where)
    local res = self:query(sql, 1)
    if res then
        count = tonumber(res[1]['NUM']) or 0
    end
    return count
end

function _M:find(tb_name, where, field, order, sql)
    if not sql then
        where = where or '1=1'
        field = field or '*'
        order = order and string.format('order by %s', order) or ''
        if type(field) == 'table' then
            field = string.format('`%s`', table.concat(field, '`,`'))
        end
        sql = string.format("SELECT %s FROM %s WHERE %s %s limit 1",
        field, tb_name, where, order)
    end
    
    local res = self:query(sql, 1)
    if not res then
        return false
    end
    return res[1]
end

function _M:find_first(tb_name, where, field, order, sql)
    if not sql then
        where = where or '1=1'
        field = field or 'id'
        order = order and string.format('order by %s', order) or ''
        sql = string.format("SELECT `%s` FROM %s WHERE %s %s limit 1",
        field, tb_name, where, order)
    end
    local res = self:query(sql, 1)
    if not res then
        return false
    end
    return res[1][field]
end

function _M:find_all(tb_name, where, field, order, limit, sql)
    if not sql then
        where = where or '1=1'
        field = field or '*'
        order = order and string.format('order by %s', order) or ''
        limit = limit and string.format('limit %s', limit) or ''
        if type(field) == 'table' then
            field = string.format('`%s`', table.concat(field, '`,`'))
        end
        sql = string.format("SELECT %s FROM %s WHERE %s %s %s",
        field, tb_name, where, order, limit)
    end
    
    local res = self:query(sql, 1)
    return res
end

function _M:find(tb_name, where, field, order, limit, sql)
    if not sql then
        where = where or '1=1'
        field = field or 'id'
        order = order and string.format('order by %s', order) or ''
        limit = limit and string.format('limit %s', limit) or ''
        sql = string.format("SELECT %s FROM %s WHERE %s %s %s",
        field, tb_name, where, order, limit)
    end
    
    local res = self:query(sql)
    if not res then
        return false
    end
    local t = {}
    for k, r in pairs(res) do
        t[k] = r[field]
    end
    return t
end

function _M:insert(tb_name, params)
    if type(params) ~= 'table' then
        kong.log.err('mysql insert params required table', type(params))
        return false
    end
    local field, valus = {}, {}
    local index = 1;
    for k, v in pairs(params) do
        field[index] = k
        valus[index] = ngx.quote_sql_str(v)
        index = index + 1
    end
    field = table.concat(field, '`,`')
    valus = table.concat(valus, ",")
    local sql = string.format("INSERT INTO %s (`%s`) VALUES (%s)", tb_name, field, valus)
    local res = self:query(sql)
    if not res then
        return false
    end
    return res.insert_id
end

function _M:update(tb_name, where, params)
    if type(params) ~= 'table' then
        kong.log.err('mysql update params required table')
        return false
    end
    local field = {}
    local index = 1;
    for k, v in pairs(params) do
        field[index] = string.format("`%s`=%s", k, ngx.quote_sql_str(v))
        index = index + 1
    end
    field = table.concat(field, ',')
    local sql = string.format("UPDATE %s SET %s WHERE %s", tb_name, field, where)
    local res = self:query(sql)
    if not res then
        return false
    end
    return res.affected_rows
end

function _M:delete(tb_name, where)
    local sql = string.format("DELETE FROM %s WHERE %s", tb_name, where)
    local res = self:query(sql)
    if not res then
        return false
    end
    return res.affected_rows
end

function _M:close()
    local ok, err = self.db:close()
    if not ok then
        kong.log.err("failed to close: ", err)
        return false
    end
    return true
end

return _M
