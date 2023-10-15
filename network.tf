# Create aws-vpc with dns support
resource "aws_vpc" "ayano_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "ayano_vpc_${random_uuid.project_id.result}"
    SECURITY_CONTACT_EMAIL = var.email
  }
}

# Create a public subnet
resource "aws_subnet" "ayano_pub_subnet" {
  vpc_id     = aws_vpc.ayano_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "ayano_pub_subnet_${random_uuid.project_id.result}"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "ayano_internet_gw" {
  vpc_id = aws_vpc.ayano_vpc.id

  tags = {
    Name = "ayano_internet_gw_${random_uuid.project_id.result}"
  }
}

# Create elastic ip address for NAT gw
resource "aws_eip" "ayano_eip" {
  domain = "vpc"

  associate_with_private_ip = "10.0.0.12"
  depends_on                = [aws_internet_gateway.ayano_internet_gw]
}

# Create a NAT gateway
resource "aws_nat_gateway" "ayano_nat_gw" {
  allocation_id = aws_eip.ayano_eip.id
  subnet_id     = aws_subnet.ayano_pub_subnet.id

  tags = {
    Name = "ayano_internet_gw_${random_uuid.project_id.result}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.ayano_internet_gw]
}

# Create a routing table and associate it with the subnet
resource "aws_route_table" "ayano_route_table" {
  vpc_id = aws_vpc.ayano_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ayano_internet_gw.id
  }
  tags = {
    Name = "ayano_route_table_${random_uuid.project_id.result}"
  }
}

resource "aws_route_table_association" "route_table_association" {
 subnet_id      = aws_subnet.ayano_pub_subnet.id
 route_table_id = aws_route_table.ayano_route_table.id
}

# Create a key_pair for ssh connections
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws_key" {
  key_name = "ansible-ssh-key"
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

# Create security group to allow HTTPs
resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.ayano_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.ayano_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_https_${random_uuid.project_id.result}"
  }
}

# Create security group to allow HTTP
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.ayano_vpc.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.ayano_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_${random_uuid.project_id.result}"
  }
}

# Create security group to allow SSH
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.ayano_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.ayano_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_${random_uuid.project_id.result}"
  }
}
