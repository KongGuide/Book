local typedefs = require "kong.db.schema.typedefs"

return {
    name = "kong-waf",
    fields = {
        {consumer = typedefs.no_consumer},
        {run_on = typedefs.run_on_first},
        {protocols = typedefs.protocols_http},
        {config = {
            type = "record",
            fields = {
                {whitelist = {type = "array", elements = typedefs.cidr_v4, }, },
                {blacklist = {type = "array", elements = typedefs.cidr_v4, }, },
                {waf_enable = {type = "boolean", required = true, default = true}, },
                {log_dir = {type = "string", required = true, default = "/usr/local/kong/logs"}, },
                {white_url_check = {type = "boolean", required = true, default = false}, },
                {url_check = {type = "boolean", required = true, default = true}, },
                {url_args_check = {type = "boolean", required = true, default = true}, },
                {user_agent_check = {type = "boolean", required = true, default = true}, },
                {cookie_check = {type = "boolean", required = true, default = true}, },
                {post_check = {type = "boolean", required = true, default = false}, },
                {waf_redirect_url = {type = "string", required = true, default = "www.deny.com"}, },
                {waf_redirect = {type = "boolean", required = true, default = false}, },
                {version = {type = "number", required = true, default = 1, },}
            },
            
        },

    },
}}
