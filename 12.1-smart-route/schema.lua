return {
    no_consumer = true,
    fields = {
        upstream_service_name = {required = true, type = "string"},
        header_key_name = {required = true, type = "string"},
        cookie_key_name = {required = true, type = "string"},
        query_key_name = {required = true, type = "string"},
        identify_values = {required = true, type = "array"},
        data_version = {required = true, type = "number"},
        identify_source = {type = "string", enum = {"header", "query", "cookie"}, default = "header"},
    }}
    
