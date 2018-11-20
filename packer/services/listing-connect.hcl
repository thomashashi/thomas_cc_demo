service {
  name = "listing"
  address = ""
  enable_tag_override = false
  port = 8000
  tags = ["prod"]

  connect = {
    proxy = {
      config = {
        upstreams = [
          {
            destination_name = "mongodb",
            local_bind_port = 8001
          }
        ]
      }
    }
  }
}
checks = [
  {
    id = "listing-tcp"
    interval = "10s"
    name = "Listing server on 8000"
    tcp = "localhost:8000"
    timeout = "1s"
    service_id = "listing"
  },
  {
    id = "listing-health"
    interval = "10s"
    timeout = "1s"
    name = "Listing server /healthz"
    http =  "http://localhost:8000/listing/healthz",
    tls_skip_verify = true,
    service_id = "listing"
  },
  {
    id = "listing-proxy-health"
    interval = "10s"
    timeout = "1s"
    name = "Listing server /healthz"
    http =  "http://localhost:8000/listing/healthz",
    tls_skip_verify = true,
    service_id = "listing-proxy"
  },
]
