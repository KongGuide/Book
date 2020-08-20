return {
    no_consumer = true,
    fields = {
        app_name = {required = true, type = "string", default = "kong-training"},
        host = {required = true, type = "string", default = "10.129.7.155"},
        port = {required = true, type = "number", default = 3306},
        database = {required = true, type = "string", default = "kong_log"},
        user = {required = true, type = "string", default = "root"},
        password = {required = true, type = "string", default = "123456"},
        charset = {required = true, type = "string", default = "utf8"},
        timeout = {required = true, type = "number", default = 1000},
        max_packet_size = {required = true, type = "number", default = 1048576},
        max_idle_timeout = {required = true, type = "number", default = 10000},
        pool_size = {required = true, type = "number", default = 10},
        tab_name = {required = true, type = "string", default = "access_log"},
        
    }
}
    
