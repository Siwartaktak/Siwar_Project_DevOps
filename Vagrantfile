# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # --------------------------
  # BASE BOX
  # --------------------------
  config.vm.box = "ubuntu/focal64"  # Ubuntu 20.04 LTS (Focal)

  # --------------------------
  # NETWORK (PORT FORWARDING)
  # --------------------------
  # Jenkins on port 8080
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  # SonarQube on port 9000
  config.vm.network "private_network", ip: "192.168.56.10"
  # Nexus Repository Manager on port 8081
  config.vm.network "forwarded_port", guest: 8081, host: 8081
  # Grafana on port 3000
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  # Prometheus on port 9090
  config.vm.network "forwarded_port", guest: 9090, host: 9090

  # --------------------------
  # VM RESOURCES
  # --------------------------
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "8192"   # 8 GB RAM (needed for Jenkins + SonarQube)
    vb.cpus = 4
  end

  # --------------------------
  # PROVISIONING SCRIPT
  # --------------------------
  config.vm.provision "shell", inline: <<-SHELL
    echo "Updating packages..."
    sudo apt-get update -y

    echo "Installing Java 11..."
    sudo apt-get install -y openjdk-11-jdk

    echo "Installing Git..."
    sudo apt-get install -y git

    echo "Installing Maven..."
    sudo apt-get install -y maven

    echo "Installing Docker..."
    sudo apt-get install -y docker.io
    sudo usermod -aG docker vagrant

    echo "Installing Docker Compose..."
    sudo apt-get install -y docker-compose

    echo "Provisioning completed!"
  SHELL
end
