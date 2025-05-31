#this script is used to create multiple ec2 instances in aws with using existing vpc and subnet
#references: https://spacelift.io/blog/terraform-ec2-instance#how-to-create-multiple-ec2-instances-with-different-configurations

# Create a security group
resource "aws_security_group" "allow_ssh_and_http" {
  name        = "allow_ssh_and_http"
  description = "Allow SSH and HTTP access"

  # Inbound rule for SSH (port 22)
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["118.99.115.149/32"]  # Replace <your-ip> with your public IP
  # }

  # Allow all inbound traffic from the same security group
  # This is critical for instances to communicate with each other
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    self        = true  # Critical: Allows members of this SG to talk to each other
  }

  # Inbound rule for HTTP (port 80)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["182.253.169.112/32"]  # Allow HTTP traffic from anywhere
  }

  # Outbound rule (allow all traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all_port_for_my_device"
  }
}

# Create an EC2 instance and attach the key pair and security group
resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-084568db4383264d4"  #ubuntu 22.04 ami 64 bit non arm
  #ami           = "ami-0953476d60561c955"  #amazon linux 2023 ami 64 bit non arm
  #ami           = "ami-05a3e0187917e3e24"  #amazon linux 2023 ami 64 bit arm
  instance_type = "t3.small"
  key_name      = "test"  # Attach the key pair
  count = 2 # Create instances with identical configurations

  # Enable public IP
  associate_public_ip_address = true

  # Attach the security group
  vpc_security_group_ids = [aws_security_group.allow_ssh_and_http.id]
  lifecycle {
    create_before_destroy = true
  }
  # Create on spot instances with specific options
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.02"
      spot_instance_type = "persistent"
      instance_interruption_behavior = "stop"
    }
  }

  # User data to install and start Apache web server
  # user_data = <<-EOF
  #             #!/bin/bash
  #             sudo yum update -y
  #             sudo yum install -y httpd
  #             sudo systemctl start httpd
  #             sudo systemctl enable httpd
  #             echo "<h1>Hello from $(hostname -f)</h1>" | sudo tee /var/www/html/index.html
  #             EOF

  tags = {
    Name = "my-ec2-instance"
  }
}

# Output the public IP of the EC2 instance
output "public_ip" {
  value = aws_instance.my_ec2_instance[*].public_ip
}

# enable terraform remote backend and state locking
terraform {
  backend "s3" {
    bucket         = "terraform-101001"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_locks"
  }
}

