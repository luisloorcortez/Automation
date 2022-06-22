provider "aws" {
region="us-west-1"
}


#This's the basic configuratioin for instamce, in this case, ubuntu. 
data "aws_ami" "ubuntu" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


#Resources

#ssh key
variable "ssh_key_path" {}
variable "vpc_id" {}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.ssh_key_path)
}


#Make security group and rules to this. (PD)
resource "aws_security_group" "allow_test_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #Open to all for test...
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #Open to all for test...
  }

  tags = {
    Name = "allow_ssh"
  }
}


#values ​​to register
resource "aws_instance" "test-qa" {
  ami           = data.aws_ami.ubuntu.id           #image to use.
  instance_type = "t3.micro"                       #type instance
  key_name = aws_key_pair.deployer.key_name        #key_name-ssh (PD)
  vpc_security_group_ids = [
    aws_security_group.allow_test_ssh.id           #add to security_group (PD+)
  ]
  tags = {
    Name = "Test-QA"                               #name, obviously...
  }
}

#Outputs
output "Test-QA" {
  value = aws_instance.test-qa.public_ip
}
