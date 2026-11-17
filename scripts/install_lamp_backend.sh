#!/bin/bash
# Capa 3: instala MariaDB (MySQL en Debian 12) y crea la base de datos de la aplicación

# Muestra cada orden y para si alguna falla
set -ex

# Cargamos las variables
source /vagrant/scripts/.env
export DEBIAN_FRONTEND=noninteractive

# 1. Actualizar la lista de paquetes
apt-get update

# 2. Instalar MariaDB y el cortafuegos
apt-get install -y mariadb-server ufw

# 3. MariaDB solo escucha en la red backend (no en todas las interfaces)
sed -i "s/^bind-address.*/bind-address = $BBDD_IP/" /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb

# 4. Crear la base de datos y la tabla de la aplicación
mysql -u root <<EOF
DROP DATABASE IF EXISTS $DB_NAME;
CREATE DATABASE $DB_NAME CHARSET utf8mb4;
USE $DB_NAME;
CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  age INT UNSIGNED NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
EOF

# 5. Crear el usuario de la aplicación (solo desde la red backend)
mysql -u root <<EOF
DROP USER IF EXISTS '$DB_USER'@'192.168.20.%';
CREATE USER '$DB_USER'@'192.168.20.%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'192.168.20.%';
FLUSH PRIVILEGES;
EOF

# 6. Cortafuegos (grupo de seguridad + ACL de la subred backend)
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp                                        # SSH para administrar (vagrant ssh)
ufw allow from $RED_BACKEND to any port 3306 proto tcp  # MariaDB solo desde la red backend
ufw --force enable
