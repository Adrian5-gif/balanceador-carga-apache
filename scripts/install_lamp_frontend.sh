#!/bin/bash
# Capa 2: instala Apache y PHP en los servidores web

# Muestra cada orden y para si alguna falla
set -ex

# Cargamos las variables
source /vagrant/scripts/.env
export DEBIAN_FRONTEND=noninteractive

# 1. Actualizar la lista de paquetes
apt-get update

# 2. Instalar Apache, PHP, el módulo de PHP para Apache, la extensión de MySQL, git y el cortafuegos
apt-get install -y apache2 php libapache2-mod-php php-mysql git ufw

# 3. Copiar el VirtualHost por defecto y reiniciar Apache
cp /vagrant/conf/000-default.conf /etc/apache2/sites-available/000-default.conf
systemctl restart apache2

# 4. Cortafuegos (grupo de seguridad + ACL de la subred frontend)
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp                                       # SSH para administrar (vagrant ssh)
ufw allow from $RED_FRONTEND to any port 80 proto tcp  # HTTP solo desde la red del balanceador
ufw --force enable
