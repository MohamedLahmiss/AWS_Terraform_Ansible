# Create an EC2-instance
resource "aws_instance" "ayano_server" {
  count = var.instance_count # here we define with the variable instance_count how many servers we want to create (see variables.tf)
  ami = var.instance_ami
  instance_type = var.instance_type
  key_name = aws_key_pair.aws_key.key_name
  associate_public_ip_address = true
  subnet_id = aws_subnet.ayano_pub_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]
  
  tags = {
    Name = element(var.instance_tags, count.index)
  }
}