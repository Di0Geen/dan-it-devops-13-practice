Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  config.vm.define "jenkins-master" do |master|
    master.vm.hostname = "jenkins-master"
    master.vm.network "private_network", ip: "192.168.56.10"
    master.vm.network "forwarded_port", guest: 8080, host: 8080

    master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end

    master.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl gnupg git

      curl -fsSL https://get.docker.com | sudo sh
      sudo usermod -aG docker vagrant

      docker run -d \
        --name jenkins \
        --restart=unless-stopped \
        -p 8080:8080 \
        -p 50000:50000 \
        -v jenkins_home:/var/jenkins_home \
        jenkins/jenkins:lts
    SHELL
  end

  config.vm.define "jenkins-worker" do |worker|
    worker.vm.hostname = "jenkins-worker"
    worker.vm.network "private_network", ip: "192.168.56.11"

    worker.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end

    worker.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl gnupg git openjdk-17-jdk

      curl -fsSL https://get.docker.com | sudo sh
      sudo usermod -aG docker vagrant
    SHELL
  end
end