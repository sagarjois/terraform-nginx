data "aws_ami" "debian" {
    most_recent = true
    filter {
        name = "name"
        values = ["debian-stretch-hvm-x86_64-gp2-2018-05-14-16107"]
    }

    owners = ["379101102735"]
}