resource "aws_security_group" "allow_ports" {
  
  name        = "allow_ports_owncloud"
  description = "Allow :80 and :443 traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port       = 0
    to_port         = 65535 
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags {
    Name = "allow_ports_owncloud"
  }
}

