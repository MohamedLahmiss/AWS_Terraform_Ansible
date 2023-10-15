# Store private_key
resource "local_sensitive_file" "private_key" {
  content = tls_private_key.rsa-4096.private_key_pem
  filename          = format("%s/%s/%s", abspath(path.root), ".ssh", "ansible-ssh-key.pem")
  file_permission   = "0600"
}

# Create the inventory file using the template file
resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tftpl", {
    ip_addrs = [for i in aws_instance.ayano_server:i.public_ip]
    ssh_keyfile = local_sensitive_file.private_key.filename
    instance_user = "${var.instance_user}"
  })
  filename = format("%s/%s", abspath(path.root), "inventory.ini")
}