service {
  name = "client"
  address = ""
  enable_tag_override = false
  port = 80
  tags = ["prod"]

  checks = [
    {
      id = "client-tcp"
      interval = "10s"
      name = "index server on 80"
      tcp = "localhost:80"
      timeout = "1s"
    },
    {
      id = "client-health"
      interval = "10s"
      timeout = "1s"
      name = "client server /healthz"
      http =  "http://localhost/healthz",
      tls_skip_verify = true,
    }
  ] 

  connect = {
    proxy = {
      config = {
        upstreams = [
          {
            destination_name = "listing",
            local_bind_port = 80
          },
          {
            destination_name = "product"
            local_bind_port  = 80
          }
        ]
      }
    }
  }
}
