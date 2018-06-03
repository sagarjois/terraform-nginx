# AWS Config

variable "aws_access_key" {
    default = ""
}

variable "aws_secret_key" {
    default = ""
}

variable "aws_region" {
    default = "ap-south-1"
}

variable "aws_availability_zones" {
    default = {
        "0" = "ap-south-1a"
    }
}
