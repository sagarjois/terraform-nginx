The goal of this project is to easily run containerized nginx server on AWS using Terraform.

The instances are based on Debian Stretch.

* "files" folder contains the Dockerfile to build nginx container and also a simple HTML file to serve.

* "aws_ami.tf" file contains the AMI data to run on EC2. We're using the latest debian stretch image and also defining the owner of the image. Based on the AWS region, it'll filter the AMI ID to use.

* "main.tf" file contains configuration related to creating and configuring resources on AWS like EC2 instance, ELB(Elastic Load Balancer), Security Groups etc. We require three resources in order to run our containerized nginx server,

1. EC2 instance to run our docker container, to do that we'll have to define what AMI we want to run on the instance which is debian stretch image which we defined in the aws_ami.tf file then the type of instance which is t2.micro, key name to use to ssh into the instance, security groups for the instance. Here we are using two provisioners, one to copy the contents of "files" folder into the home folder of the instance which contains Dockerfile and HTML file which we want to serve and the other provisioner "remote-exec" to execute the commands to install docker, build the Dockerfile and run the built image on the instance. Note that for both provisioner to work we'll have to ssh into the instance so you'll need to create the keypair first and define the path of the keypair file inside connection block in main.tf file.

2. ELB to point to our instance, to do that we define the config inside aws_instance block. Here we define the listener which contains the key value pairs to configure ELB to listen on the instance port,protocol and also the load balancer port,protocol, then we define in which Availability Zone(AZ) we want ELB to be created, which is the same as our instance AZ which is defined in variables.tf file, and finally the instance to which the ELB has to point.

3. Security Group acts as a virtual firewall for the instance which is defined in the aws_security_group block. We define the name of the security group for easy identification. We have to define two ingress blocks and one egress block inside which we define what ports and protocols we want to allow to and from the instance. In the first ingress block we have defined that we want to allow ssh access on port 22 with tcp protocol from the internet to the instance, in the second ingress block we have defined to allow all the traffic from the internet on port 80 to the instance on port 80 with tcp protocol and in the egress block we have defined we want to allow all kind of traffic from the instance to the internet.  

* "outputs.tf" file defines the values we want to see in the terminal after all the resources have been successfully created, we have defined ELB address and the IP address of the instance to show up in terminal.

* "providers.tf" file defines The Amazon Web Services (AWS) provider which is used to interact with many resources supported by AWS. The provider needs to be configured with proper credentials before it can be used. The AWS provider offers a flexible means of providing credentials for authentication. The following methods are supported,

* Static credentials
* Environment variables
* Shared credentials file
* EC2 Role

    Here we're using static credentials method, and we are taking the values from variables.tf file.

    Static credentials can be provided by adding an access_key and secret_key in-line in the AWS provider block:

    provider "aws" {
    region     = "us-west-2"
    access_key = "anaccesskey"
    secret_key = "asecretkey"
    }

* Edit variables.tf file which contains credential and config information, feel free to add in your own default values. 

* You'll have to place the EC2 key pair private ".pem" file in the same level as main.tf file or specify relative path to ".pem" file in the connection block for "private_key" inside file function in main.tf file.

* After cloning this repo, cd into the folder and execute the command "terraform init" to initialize and download provider(AWS) plugins.

* After editing the variables.tf file, execute "terraform plan" which shows all the resources which is going to be created and also the config for those resources required to run the app, the resources are still not created at this step.

* To create all the resources and run the app, execute the command "terraform apply".

* If you want to destroy/delete all the resources created by terraform, execute the command "terraform destroy".



