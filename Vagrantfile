# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "hashicorp/bionic64"
  config.vm.box_version = "1.0.282"
  config.vm.network :forwarded_port, guest:8000, host:8000, host_ip: "127.0.0.1"

  config.vm.provision "shell", path: "provision-os.sh"
  config.vm.provision "shell", path: "provision-python.sh"
  config.vm.provision "shell", path: "provision-db.sh"
  config.vm.provision "shell", path: "provision-gcd.sh", privileged: "false"
end
