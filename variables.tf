#configuração geral
variable "credentials_file" {
  default = "~/.aws/credentials"
}

variable "profile" {
  default = "default"
}

variable "region" {
  default = "us-east-1"
}

variable "ami" {
  default = "ami-14c5486b"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "keyname" {
  default = "keypair-user4automation"
}

variable "vpc_sg_ids" {
  default = "sg-e51b9aad"
}

variable "subnet_id" {
  default = "subnet-0a778e56"
}

variable "volume_size" {
  default = "20"
}

variable "volume_type" {
  default = "gp2"
}

variable "delete_termination" {
  default = "True" 
}

variable "name_server" {
  default = "server-owncloud"
}

variable "vpc-fullcidr" {
  default = "172.31.0.0/16"
}
