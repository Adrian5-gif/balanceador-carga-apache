#!/bin/bash
# Capa 1: instala Apache y lo configura como balanceador de carga (proxy inverso)

# Muestra cada orden y para si alguna falla
set -ex

# Cargamos las variables
source /vagrant/scripts/.env
export DEBIAN_FRONTEND=noninteractive

# 1. Actualizar la lista de paquetes
apt-get update

# 2. Instalar Apache y el cortafuegos
apt-get install -y apache2 ufw

# 3. Activar los módulos de proxy inverso y balanceo Round Robin
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests

# 4. Copiar el VirtualHost del balanceador y poner las IPs y el dominio
cp /vagrant/conf/load-balancer.conf /etc/apache2/sites-available/load-balancer.conf
sed -i "s/IP_HTTP_SERVER_1/$WEB1_IP/" /etc/apache2/sites-available/load-balancer.conf
sed -i "s/IP_HTTP_SERVER_2/$WEB2_IP/" /etc/apache2/sites-available/load-balancer.conf
sed -i "s/DOMINIO/$DOMAIN/"           /etc/apache2/sites-available/load-balancer.conf

# 5. Activar el balanceador y desactivar el sitio por defecto
a2ensite load-balancer.conf
a2dissite 000-default.conf

# 6. Reiniciar Apache
systemctl restart apache2

# 7. Cortafuegos (grupo de seguridad de la capa pública)
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp    # SSH para administrar (vagrant ssh)
ufw allow 80/tcp    # HTTP desde cualquier sitio
ufw allow 443/tcp   # HTTPS desde cualquier sitio
ufw --force enable
