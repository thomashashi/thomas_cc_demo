resource "google_kms_key_ring" "vault-keyring" {
  name     = "vault-keyring"
  location = "global"
}

resource "google_kms_crypto_key" "vault-key" {
  name            = "vault-key"
  key_ring        = "${google_kms_key_ring.vault-keyring.id}"
  rotation_period = "100000s"
}
