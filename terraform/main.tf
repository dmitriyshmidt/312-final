resource "aws_instance" "minecraft" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name = var.key_name
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.minecraft.id]
  associate_public_ip_address = true
}

resource "null_resource" "provision_minecraft" {
  depends_on = [aws_instance.minecraft,
  aws_security_group.minecraft
]

  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file(var.private_key_path)
    host = aws_instance.minecraft.public_ip
  }

  provisioner "file" {
    source = "${path.module}/../scripts/setup_mc.sh"
    destination = "/home/ec2-user/setup_mc.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/setup_mc.sh",
      "sudo /home/ec2-user/setup_mc.sh"
    ]
  }
}

resource "aws_security_group" "minecraft" {
  name = "minecraft-sg"
  description = "Allows SSH and Minecraft traffic"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow Minecraft"
    from_port = 25565
    to_port = 25565
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "minecraft-sg"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["137112412989"] # Official Amazon Linux AMI publisher

  filter {
    name = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}
