local typedefs = require "kong.db.schema.typedefs"
local types = require "kong.plugins.kong-kafka-log.types"


--- Validates value of `bootstrap_servers` field.
local function check_bootstrap_servers(values)
  if values and 0 < #values then
    --kong.log.err("Values is set to: " .. values)
    for _, value in ipairs(values) do
      local server = types.bootstrap_server(value)
      if not server then
        return false, "invalid bootstrap server value: " .. value
      end
    end
    return true
  end
  return false, "bootstrap_servers is required"
end

return {
  name = "kong-kafka-log",
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { bootstrap_servers = {
              type = "array",
              custom_validator = check_bootstrap_servers,
              elements = {
                type = "string"
          }, }, },
          { topic = { type = "string", required = true }, },
          { app_name = { type = "string", required = true }, },
          { timeout = { type = "number", default = 10000 }, },
          { keepalive = { type = "number", default = 60000 }, },
          { ssl = { type = "boolean", default = false }, },
          { ssl_verify = { type = "boolean", default = false }, },
          { producer_request_acks = { type = "number", default = 1, one_of = { -1, 0, 1 }, }, },
          { producer_request_timeout = { type = "number", default = 2000 }, },
          { producer_request_limits_messages_per_request = { type = "number", default = 200 }, },
          { producer_request_limits_bytes_per_request = { type = "number", default = 1048576 }, },
          { producer_request_retries_max_attempts = { type = "number", default = 10 }, },
          { producer_request_retries_backoff_timeout = { type = "number", default = 100 }, },
          { producer_async = { type = "boolean", default = true }, },
          { producer_async_flush_timeout = { type = "number", default = 1000 }, },
          { producer_async_buffering_limits_messages_in_memory = { type = "number", default = 50000 }, },
    }, }, },
  },
}
