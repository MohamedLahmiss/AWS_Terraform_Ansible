variable "email" {
  type = string
  default = "vagrant@local.com"
}

variable "region" {
  type = string
  default = "eu-central-1"
}

variable "instance_ami" {
  type = string
  default = "ami-0ebc281c20e89ba4b"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

# below we define the default server names
variable "instance_tags" {
  type = list(string)
  default = ["tf-ansible-1", "tf-ansible-2", "tf-ansible-3", "tf-ansible-4", "tf-ansible-5"]
}

variable "instance_count" {
  type = number
  default = 1
}

variable "instance_user" {
  type = string
  default = "ec2-user"
}