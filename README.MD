# Jenkins Lab Setup Guide

This guide explains how to build a Jenkins AMI using Packer, run a Vagrant environment, and launch an AWS EC2 instance using the AWS CLI.

---

## Prerequisites

- [Packer](https://www.packer.io/downloads)
- [Vagrant](https://www.vagrantup.com/downloads)
- [AWS CLI](https://aws.amazon.com/cli/)

---

## 1. Build Jenkins AMI with Packer

1. **Configure AWS Credentials:**
	Ensure your AWS credentials are set up so Packer can authenticate with AWS. Run:
	```sh
	aws configure
	```
	Follow the prompts to enter your AWS Access Key ID, Secret Access Key, region, and output format.

2. Navigate to the `packer` directory:
	```sh
	cd packer
	```
3. Initialize Packer:
	```sh
	packer validation jenkins-ami.pkr.hcl
	packer init jenkins-ami.pkr.hcl
	```
4. Build the AMI:
	```sh
	packer build jenkins-ami.pkr.hcl
	```

---

## 2. Run Vagrant Environment

1. Navigate to the `vagrant` directory:
	```sh
	cd vagrant
	```
2. Start the Vagrant environment:
	```sh
	vagrant up
	```

---

## 3. Launch AWS EC2 Instance

After building the AMI, use the following AWS CLI commands (update IDs as needed):

1. **Create Security Group:**
	```sh
	aws ec2 create-security-group \
	   --group-name "jenkins-lab-sg" \
	   --description "jenkins-lab-sg created 2025-07-23T16:54:31.791Z" \
	   --vpc-id "<your-vpc-id>"
	```

2. **Authorize Security Group Ingress:**
	```sh
	aws ec2 authorize-security-group-ingress \
		--group-id "sg-xxxxxxxxxxxx" \
		--ip-permissions '[
			{"IpProtocol":"tcp","FromPort":22,"ToPort":22,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]},
			{"IpProtocol":"tcp","FromPort":443,"ToPort":443,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]},
			{"IpProtocol":"tcp","FromPort":80,"ToPort":80,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]},
			{"IpProtocol":"tcp","FromPort":8080,"ToPort":8080,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}
		]'
	```

3. **Run EC2 Instance:**
	```sh
	aws ec2 run-instances \
	   --image-id "<your-ami-id>" \
	   --instance-type "t2.micro" \
	   --key-name "<your-private-key>" \
	   --network-interfaces '{"AssociatePublicIpAddress":true,"DeviceIndex":0,"Groups":["sg-xxxxxxxxxxxx"]}' \
	   --credit-specification '{"CpuCredits":"standard"}' \
	   --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"jenkins-02"}]}' \
	   --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":true,"EnableResourceNameDnsAAAARecord":false}' \
	   --count "1"
	```

---

## Notes

- Replace security group IDs, VPC IDs, and AMI IDs as appropriate for your environment.
- Ensure your AWS user has sufficient permissions.

---