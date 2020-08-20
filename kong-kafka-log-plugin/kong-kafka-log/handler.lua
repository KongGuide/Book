local producers = require "kong.plugins.kong-kafka-log.producers"
local cjson = require "cjson"
local cjson_encode = cjson.encode
local tonumber = tonumber
local osdate = os.date
local kong = kong
local producer

local KongKafkaLogHandler = {}

KongKafkaLogHandler.PRIORITY = 5
KongKafkaLogHandler.VERSION = "1.0.0"

--- Publishes a message to Kafka.
-- Must run in the context of `ngx.timer.at`.
local function log(premature, conf, message)
    if premature then
        return
    end
    
    if not producer then
        local err
        producer, err = producers.new(conf)
        if not producer then
            kong.log.err("[kong-kafka-log] failed to create a Kafka Producer for a given configuration: ", err)
            return
        end
    end
    
    local ok, err = producer:send(conf.topic, nil, cjson_encode(message))
    if not ok then
        kong.log.err("[kong-kafka-log] failed to send a message on topic ", conf.topic, ": ", err)
        return
    end
end

local function build_message(conf)
    
    return {
        
        name = conf.app_name,
        date_time = osdate("%Y-%m-%d %H:%M:%S"),
        remote_addr = kong.client.get_ip(),
        forwarded_ip = kong.client.get_forwarded_ip(),
        status = kong.response.get_status(),
        method = kong.request.get_method(),
        upstream_addr = ngx.var.upstream_addr,
        upstream_response_time = ngx.var.upstream_response_time,
        http_host = kong.request.get_host(),
        query_string = kong.request.get_raw_query(),
        uri = kong.request.get_path(),
        referer = ngx.var.referer,
        user_agent = kong.request.get_header("User-Agent"),
        request_time = ngx.var.request_time,
        ssl = ngx.var.ssl_protocol,
        machine = ngx.var.hostname,
        in_bytes = ngx.var.request_length,
        out_bytes = ngx.var.bytes_sent,
    }

end

function KongKafkaLogHandler:log(conf)
    --local message = basic_serializer.serialize(ngx, nil, conf)
    local message = build_message(conf)
    local ok, err = ngx.timer.at(0, log, conf, message)
    if not ok then
        kong.log.err("[kong-kafka-log] failed to create timer: ", err)
    end
end

return KongKafkaLogHandler
