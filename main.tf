resource "aws_security_group" "sg" {

    name = "sg"
    description = "AWS security group for terraform"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "Terraform AWS security group"
    }
}


resource "aws_elb" "web" {
    name = "terraform"

    listener {
        instance_port     = 80
        instance_protocol = "http"
        lb_port           = 80
        lb_protocol       = "http"
    }

    availability_zones = [
        "${lookup(var.aws_availability_zones, count.index)}"
    ]

    instances = [
        "${aws_instance.web.*.id}"
    ]
}

resource "aws_instance" "web" {
    ami           = "${data.aws_ami.debian.id}"
    instance_type = "t2.micro"

    availability_zone = "${lookup(var.aws_availability_zones, count.index)}"

    key_name = "admin"
    security_groups = [ "${aws_security_group.sg.*.name}" ]


    provisioner "file" {
        source = "files/"
        destination = "$HOME"
        connection {
            type = "ssh"
            user = "admin"
            private_key = "${file("./admin.pem")}"
        }
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y apt-transport-https ca-certificates wget software-properties-common",
            "echo \"deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable\" | sudo tee -a /etc/apt/sources.list.d/docker.list",
            "sudo apt-get update",
            "sudo apt-get -y install docker-ce --allow-unauthenticated",
            "sudo usermod -a -G docker $USER",
            "sudo systemctl start docker",
            "sudo docker build -t nginx-server .",
            "sudo docker run -d -p 80:80 nginx-server"
        ],
        connection {
            type = "ssh"
            user = "admin"
            private_key = "${file("./admin.pem")}"
        }
    }
    
    tags {
        Name = "my-instance"
    }
}

