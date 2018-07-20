#connect {
#    enabled = true
#    ca_provider = "vault"
#    ca_config {
#        address = "http://active.vault.service.consul:8200"
#        token = "consul-server-token"
#        root_pki_path = "connect-root"
#        intermediate_pki_path = "connect-intermediate"
#    }
#}