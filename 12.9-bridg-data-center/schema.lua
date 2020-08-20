return {
  no_consumer = true,
  fields = {
    --上游服务器名称
    upstream_service_name = { required = true, type = "string" },
    --失效备援的上游服务器数据中心，北京、上海
    failover_data_center = { type = "string", enum = {"beijing", "shanghai"}, default = "beijing" },
  }
}
