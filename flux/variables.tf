variable "github_token" {
  sensitive = true
  type      = string
}

variable "github_org" {
  type = string
  default = "patrickkenney9801"
}

variable "github_repository" {
  type = string
  default = "observability"
}

variable "kube_context" {
  type = string
}

variable "cluster" {
  type = string
  default = "dev"
}
