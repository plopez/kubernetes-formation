terraform {
  backend "gcs" {
    bucket = "wsc-training-tfstates"
    prefix = "k8s-training-niv-1" //project = "wsc-training-deploy"
  }
}

provider "google" {
  project     = terraform.workspace
  region      = "europe-west1"
  alias = "default"
}

module "bootstrap-training" {
  /*providers = {
    google = google.default
  }*/

  MOD_REGION    = "europe-west1"
  MOD_COUNT     = 1
  MOD_PROJECT = terraform.workspace

  source = "./modules"
}


output bastion_ip {
  value = module.bootstrap-training.bastion_ip
}

output password {
  value = module.bootstrap-training.password
  sensitive = true
}