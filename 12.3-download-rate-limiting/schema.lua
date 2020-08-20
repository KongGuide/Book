return {
    no_consumer = true,
    fields = {
        data_version = {required = true, type = "number"},
        default_rate_limiting = {required = true, type = "string", default = "100K"},
        user_id_header_name = {required = true, type = "string", default = "user_id"},
        user_limit_values = {required = true, type = "array",
        default = {"10000001:500K", "10000002:800K"}},
    }}

   