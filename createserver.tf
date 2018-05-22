provider "aws" {
  shared_credentials_file = "${var.credentials_file}"
  profile = "${var.profile}"
  region = "${var.region}"


}

resource "aws_instance" "owncloud" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.keyname}"
  user_data = "${file("template.sh")}"
  vpc_security_group_ids = ["${aws_security_group.allow_ports.id}"]
 root_block_device {
    volume_size = "${var.volume_size}"
    volume_type = "${var.volume_type}"
    delete_on_termination = "${var.delete_termination}"
  }

  tags {
    Name = "${var.name_server}"
  }
 lifecycle {
	ignore_changes = ["aws_instance.owncloud.id"]
}
}
