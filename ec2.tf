#provider block

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

#Variables

#Create EC2 instance
resource "aws_instance" "TestInstance1" {
  ami             = "${data.aws_ami.TestAMI.id}"
  instance_type   = "${var.instance_type}"
  count = 1
  key_name = "awskey1"
  vpc_security_group_ids = [
      "${aws_security_group.webSG.id}",
  ]
  tags = {
    Name = "HelloWorld"
  }

   connection {
    type = "ssh"
    user = "ec2-user"
    host = "${self.public_ip}"
    private_key = "${file("awskey1.pem")}"
  }

  
#provisioners - File 
   
  provisioner "file" {
    source      = "playbook.yaml"
    destination = "/tmp/playbook.yaml"

 }

  #provisioners - remote-exec 
  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install  ansible2 -y",
      "sleep 10s",
      "sudo ansible-playbook -i localhost /tmp/playbook.yaml",
      "sudo chmod 657 /var/www/html"
    ]
    
  }

   provisioner "file" {
    source      = "index.html"
    destination = "/var/www/html/index.html"

 }

  }

  

# data source - AMI
data "aws_ami" "TestAMI" {
  most_recent = true
  owners = ["amazon"]

  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }
}

#resources

#Create Security Group  
resource "aws_security_group" "webSG" {
  name        = "webSG"
  description = "Allow ssh  inbound traffic"
  vpc_id      = "vpc-d12868ab"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}



#outputs

output "TestInstance1_pub_ip" {
    value = "${aws_instance.TestInstance1.0.public_ip}"
}

output "TestInstance1_id" {
    value = "${aws_instance.TestInstance1.0.id}"
}