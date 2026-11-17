# -*- mode: ruby -*-
# vi: set ft=ruby :

# Balanceador de carga con Apache - Arquitectura en tres niveles
#
#   Capa 1 (pública)  -> AdrianRiosBalanceador  (reenvío de puertos 80 y 443)
#   Capa 2 (privada)  -> AdrianRiosWeb1 y AdrianRiosWeb2
#   Capa 3 (privada)  -> AdrianRiosBBDD
#
#   red_frontend: 192.168.10.0/24  (balanceador <-> servidores web)
#   red_backend : 192.168.20.0/24  (servidores web <-> base de datos)

Vagrant.configure("2") do |config|

  # Debian 12 (Bookworm) para todas las máquinas
  config.vm.box = "debian/bookworm64"

  # ---------- CAPA 3: BASE DE DATOS ----------
  config.vm.define "bbdd" do |bbdd|
    bbdd.vm.hostname = "AdrianRiosBBDD"
    bbdd.vm.network "private_network", ip: "192.168.20.13", virtualbox__intnet: "red_backend"
    bbdd.vm.provider "virtualbox" do |vb|
      vb.name   = "AdrianRiosBBDD"
      vb.memory = 1024
    end
    bbdd.vm.provision "shell", path: "scripts/install_lamp_backend.sh"
  end

  # ---------- CAPA 2: SERVIDORES WEB ----------
  # Se crean dos máquinas iguales: web1 y web2
  [1, 2].each do |i|
    config.vm.define "web#{i}" do |web|
      web.vm.hostname = "AdrianRiosWeb#{i}"
      web.vm.network "private_network", ip: "192.168.10.1#{i}", virtualbox__intnet: "red_frontend"
      web.vm.network "private_network", ip: "192.168.20.1#{i}", virtualbox__intnet: "red_backend"
      web.vm.provider "virtualbox" do |vb|
        vb.name   = "AdrianRiosWeb#{i}"
        vb.memory = 768
      end
      web.vm.provision "shell", path: "scripts/install_lamp_frontend.sh"
      web.vm.provision "shell", path: "scripts/deploy.sh"
    end
  end

  # ---------- CAPA 1: BALANCEADOR ----------
  config.vm.define "balanceador" do |lb|
    lb.vm.hostname = "AdrianRiosBalanceador"
    lb.vm.network "private_network", ip: "192.168.10.10", virtualbox__intnet: "red_frontend"

    # Única máquina accesible desde fuera (equivalente a la IP elástica de AWS)
    lb.vm.network "forwarded_port", guest: 80,  host: 80
    lb.vm.network "forwarded_port", guest: 443, host: 443

    lb.vm.provider "virtualbox" do |vb|
      vb.name   = "AdrianRiosBalanceador"
      vb.memory = 768
    end
    lb.vm.provision "shell", path: "scripts/install_load_balancer.sh"
    lb.vm.provision "https", type: "shell", path: "scripts/setup_letsencrypt_https.sh"
  end

end
