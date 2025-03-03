output "public_ip" {
  value = aws_instance.web_server.public_ip
}

output "instance_type" {
  value = aws_instance.web_server.instance_type
}

output "ami" {
  value = aws_instance.web_server.ami
}

output "instance_id" {
  value = aws_instance.web_server.id
}

output "private_ip" {
  value = aws_instance.web_server.private_ip
}

output "eni" {
  value = aws_instance.web_server.primary_network_interface_id
}

output "public_dns" {
  value = aws_instance.web_server.public_dns

}