data "template_file" "file_server_ubuntu" {
  template = file("${path.module}/templates/userdata_fileserver_ubuntu.sh")

  vars = {
    hostname        = var.hostname

  }
}

data "template_file" "file_server_rhel" {
  template = file("${path.module}/templates/userdata_fileserver_rhel.sh")

  vars = {
    hostname        = var.hostname

  }
}