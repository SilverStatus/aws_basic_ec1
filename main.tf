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

  # Inbound rule for HTTP (port 80)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["182.253.86.119/32"]  # Allow HTTP traffic from anywhere
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
  ami           = "ami-084568db4383264d4"  
  instance_type = "t2.small"
  key_name      = "test"  # Attach the key pair
  count = 2 # Create instances with identical configurations

  # Enable public IP
  associate_public_ip_address = true

  # Attach the security group
  vpc_security_group_ids = [aws_security_group.allow_ssh_and_http.id]

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

