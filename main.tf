provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"] # Canonical

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-*",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "EC2 security group"
  description = "Security group for EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "ssh_key_pair" {
  source                = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=master"
  name                  = "keypair${var.ec2_name}"
  ssh_public_key_path   = "secrets"
  generate_ssh_key      = "true"
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
  chmod_command         = "chmod 600 %v"
}

resource "aws_eip" "this" {
  vpc      = true
  instance = aws_instance.app.id
}

resource "aws_instance" "app" {
  # source = "terraform-aws-modules/ec2-instance/aws"

  # name           = "${var.ec2_name}"
  ami            = "${data.aws_ami.amazon_linux.id}"
  instance_type  = "${var.ec2_instance_type}"
  # instance_count = 1
  subnet_id      = tolist(data.aws_subnet_ids.all.ids)[0]
  //  private_ips                 = ["172.31.32.5", "172.31.46.20"]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
  key_name                    = "${module.ssh_key_pair.key_name}"

  tags = {
    Name = "${var.ec2_name}"
  }

  connection {
    type     = "ssh"
    host     = "${aws_instance.app.public_ip}"
    user     = "ec2-user"
    password = ""
    private_key = "${file("secrets/keypair${var.ec2_name}.pem")}"
  }

  # Install Docker
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      # install Docker
      "sudo yum install docker -y",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      # install Docker Compose
      "sudo curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
      "docker-compose --version",
    ]
  }

  # # Add Gitlab User
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo useradd -m gitlab",
  #     "sudo mkdir /home/gitlab/.ssh",
  #     "sudo chmod 700 /home/gitlab/.ssh",
  #     "sudo touch /home/gitlab/.ssh/authorized_keys",
  #     "sudo chmod 600 /home/gitlab/.ssh/authorized_keys",
  #     "sudo chown -R gitlab:gitlab /home/gitlab/.ssh",
  #     "sudo su gitlab",
  #     "ssh-keygen -b 2048 -t rsa -f /home/gitlab/.ssh/id_rsa -q -N ''",
  #     "cat /home/gitlab/.ssh/id_rsa.pub >> /home/gitlab/.ssh/authorized_keys",
  #     "cat /home/gitlab/.ssh/id_rsa",
  #     "exit",
  #   ]
  # }

  # # give gitlab user permission to run docker cmds
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo usermod -aG docker gitlab",
  #   ]
  # }
}
