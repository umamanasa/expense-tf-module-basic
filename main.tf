resource "aws_instance" "instance" {

  ami                     = data.aws_ami.ami.id
  instance_type           = var.instance_type
  vpc_security_group_ids  = var.security_groups

  tags = {
    Name = var.name
  }
}

resource "aws_route53_record" "record" {

  zone_id = var.zone_id
  name    = "${var.name}-dev.manasareddy.online"
  type    = "A"
  ttl     = 30
  records = [ aws_instance.instance.private_ip ]
}

resource "null_resource" "ansible" {

  depends_on = [
    aws_route53_record.record
  ]

  provisioner "local-exec" {
    command = <<EOF
cd /home/centos/expense-ansible
git pull
sleep 30
ansible-playbook -i ${var.name}-dev.manasareddy.online, main.yml -e ansible_user=centos -e ansible_password=DevOps321 -e component=${var.name}
EOF
  }
}

#
# for expense terraform main.tf code to execute tf-module-basic
#module "components" {
#
#  source   = "git::https://github.com/umamanasa/expense-tf-module-basic.git"
#  for_each = var.components
#
#  zone_id           = var.zone_id
#  security_groups   = var.security_groups
#  name              = each.value["name"]
#  instance_type     = each.value["instance_type"]
#}

##main.tfvars -- expense teraform
#components = {
#  frontend = {
#    name          = "frontend"
#    instance_type = "t2.micro"
#  }
#  mysql = {
#    name          = "mysql"
#    instance_type = "t2.micro"
#  }
#  backend = {
#    name          = "backend"
#    instance_type = "t2.micro"
#  }
#}
#
#security_groups = [ "sg-041096a23e28b0eb0" ]
#zone_id         = "Z0365188L7MG2LV8YN4J"