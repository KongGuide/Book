return {
    no_consumer = true,
    fields = {
        static_file_host = {required = true, type = "string", default = "www.static-file-server.com"},
        static_file_port = {required = true, type = "number", default = 80},
        concat_delimiter = {required = true, type = "string", default = ""},
        concat_max_files_number = {required = true, type = "number", default = 10},
        concat_max_files_size = {required = true, type = "number", default = 1048576}, --1m,
        connect_timeout = {required = true, type = "number", default = 1000}, --ms
        connect_pool_idle_timeout = {required = true, type = "number", default = 60000}, --ms
        connect_pool_size = {required = true, type = "number", default = 128},
        key_ttl = {required = true, type = "number", default = 0}, --s,0=infinite
    }
}