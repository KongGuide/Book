return {
    no_consume = true,

    fields = {
        cache_ttl = {
            type = "number",
            default = 300,
            required = true
        },
        redis = {
            type = "table",
            schema = {
                fields = {
                    host = {type = "string", required = false},
                    sentinel_master_name = {type = "string", required = false},
                    sentinel_role = {type = "string", required = false, default = "master"},
                    sentinel_addresses = {type = "array", required = false},
                    port = {
                        type = "number",
                        func = server_port,
                        default = 6379,
                        required = true
                    },
                    timeout = {type = "number", required = true, default = 2000},
                    password = {type = "string", required = false},
                    database = {type = "number", required = true, default = 0},
                    max_idle_timeout = {type = "number", required = true, default = 10000},
                    pool_size = {type = "number", required = true, default = 1000}
                }
            }
        }
    }
}
