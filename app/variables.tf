variable "region" {
  type = "string"
  default = "us-west-2"
}

variable "instance_ami" {
  type = "string"
  default = "ami-92e06fea"
}

variable "instance_size" {
  type = "string"
  default = "t2.nano"
}

variable "public_key" {
  type = "string"
}

variable "app_name" {
  type = "string"
}

variable "app_domain" {
  type = "string"
}

variable "app_image" {
  type = "string"
}

variable "app_port" {
  type = "string"
  default = "80"
}

variable "desired_count" {
  type = "string"
  default = "1"
}
