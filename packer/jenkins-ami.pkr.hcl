packer {
    required_plugins {
        amazon = {
            source  = "github.com/hashicorp/amazon"
            version = ">= 1.0.0"
        }
    }
}

variable "aws_region"{
    default = "ap-southeast-1"
}

source "amazon-ebs" "ubuntu_jenkins"{
    region                  = var.aws_region
    source_ami_filter {
        filters = {
            name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
            virtualization-type = "hvm"
            root-device-type    = "ebs"
        }
        owners      = ["099720109477"]
        most_recent = true
    }

    instance_type               = "t2.micro"
    ssh_username                = "ubuntu"
    ami_name                    = "jenkins-ubuntu24-{{timestamp}}"
    ami_description             = "Ubuntu 24.04 with Jenkins"
    associate_public_ip_address = true
}

build {
    name    = "jenkins-ubuntu24-ami"
    sources = ["source.amazon-ebs.ubuntu_jenkins"]

    provisioner "shell"{
        inline = [
            "export DEBIAN_FRONTEND=noninteractive",
            "sudo apt-get update",
            "sudo apt-get install -y fontconfig openjdk-21-jre curl gnupg2 wget",

            "sudo mkdir -p /etc/apt/keyrings",
            "wget -q -O /tmp/jenkins.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
            "sudo mv /tmp/jenkins.asc /etc/apt/keyrings/jenkins-keyring.asc",

            "echo 'deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]' https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
            "sudo apt-get update",
            "sudo apt-get install -y jenkins",
            "sudo systemctl enable jenkins",
            "sudo systemctl start jenkins"
        ]
    }
}