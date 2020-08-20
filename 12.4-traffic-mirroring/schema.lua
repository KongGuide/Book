return {
    no_consumer = true,
    fields = {
        --traffic mirroring
        traffic_mirroring_host =
        {required = true, type = "string", default = "www.mirroring.com"},
        traffic_mirroring_port = {required = true, type = "number", default = 80},
        connect_timeout = {required = true, type = "number", default = 1000}, --ms
        connect_pool_idle_timeout = {required = true, type = "number", default = 60000}, --ms
        connect_pool_size = {required = true, type = "number", default = 128
    	}
	}
}

   