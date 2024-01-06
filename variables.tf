variable "region" {
  default = "us-east-1"
}

variable "cidr" {
  default = "10.1.0.0/16"
}

variable "subcidr" {
  default = "10.1.0.0/24"
}

variable "subcidr01" {
  default = "10.1.1.0/24"
}
variable "availabilityzone01" {
  default = "us-east-1a"
}

variable "availabilityzone02" {
  default = "us-east-1b"
}


variable "ami_id" {
  default = "ami-06aa3f7caf3a30282"

}

variable "inst_type" {
  default = "t2.micro"
}