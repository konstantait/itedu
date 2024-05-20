locals {
  root = "./files/rootfs"
  
  files = [
    "/etc/resolv.conf", 
    "/etc/apparmor.d/usr.sbin.named",
    "/usr/share/dns/root.hints",
  ]
  
  folders = [
    "/etc/bind",
  ]
  
  mkdir = setunion(
    [ for path in local.files : dirname(path) ],
    [ for path in local.folders : path ],
  )
}

source "null" "test" {
  communicator = "none"
}

build {
  sources = ["null.test"]

  dynamic "provisioner" {
    for_each = local.mkdir
    labels = ["shell-local"]
    iterator = item
    content {
      inline = ["echo ${item.value}"]
    }
  }

}