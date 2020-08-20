return {
    no_consumer = true,
    fields = {
        lbs_service_host =
        {required = true, type = "string", default = "www.lbs.com"},
        lbs_service_port = {required = true, type = "number", default = 80},
        lbs_service_url = {required = true, type = "string", default = "/lbs"},
        connect_timeout = {required = true, type = "number", default = 1000}, --ms
        connect_pool_idle_timeout =
        {required = true, type = "number", default = 60000}, --ms
        connect_pool_size = {required = true, type = "number", default = 128},
        key_ttl = {required = true, type = "number", default = 0}, --s,0=infinite
    }
}

   