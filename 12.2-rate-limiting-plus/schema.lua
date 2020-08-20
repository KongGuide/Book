
return {
    fields = {
        
        debug_mode = {type = "boolean", default = true},
        header_name = {type = "string", default = "companyId"},
        limit_data_host = {required = true, type = "string", default = "10.129.171.141"},
        limit_data_port = {required = true, type = "number", default = 8000},
        limit_data_url = {required = true, type = "string", default = "/ratelimit"},
        timeout = {required = true, type = "number", default = 1000}, --ms
        key_ttl = {required = true, type = "number", default = 60}, --s
        idle_timeout = {required = true, type = "number", default = 60000}, --ms
        pool_size = {required = true, type = "number", default = 128},
        http_try_number = {required = true, type = "number", default = 3},
        policy = {type = "string", enum = {"local", "cluster", "redis"}, default = "local"},
        fault_tolerant = {type = "boolean", default = true},
        redis_host = {type = "string"},
        redis_port = {type = "number", default = 6379},
        redis_password = {type = "string"},
        redis_timeout = {type = "number", default = 2000},
        redis_database = {type = "number", default = 0},
        debug_mode = {type = "boolean", default = true},
        
    }
}
    
