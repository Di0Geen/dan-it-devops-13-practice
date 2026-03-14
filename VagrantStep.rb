Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/jammy64"

  # ---------------- DB VM ----------------
  config.vm.define "db_vm" do |db|
    db.vm.hostname = "db_vm"
    db.vm.network "private_network", ip: "192.168.56.10"

    db.vm.provision "shell", path: "db_provision.sh"
  end

  # ---------------- APP VM ----------------
  config.vm.define "app_vm" do |app|
    app.vm.hostname = "app_vm"
    app.vm.network "private_network", ip: "192.168.56.11"
    app.vm.network "forwarded_port", guest: 8080, host: 8080

    app.vm.provision "shell", path: "app_provision.sh"
  end

end