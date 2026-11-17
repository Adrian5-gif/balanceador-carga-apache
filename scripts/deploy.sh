#!/bin/bash
# Capa 2: despliega la aplicación web en los servidores web

# Muestra cada orden y para si alguna falla
set -ex

# Cargamos las variables
source /vagrant/scripts/.env

# 1. Descargar la aplicación de GitHub
rm -rf /tmp/iaw-practica-lamp
git clone $APP_REPO /tmp/iaw-practica-lamp

# 2. Borrar la página por defecto y copiar la aplicación
rm -f /var/www/html/index.html
cp -r /tmp/iaw-practica-lamp/src/* /var/www/html/

# 3. Configurar la conexión con la base de datos
sed -i "s/localhost/$BBDD_IP/"            /var/www/html/config.php
sed -i "s/database_name_here/$DB_NAME/"   /var/www/html/config.php
sed -i "s/username_here/$DB_USER/"        /var/www/html/config.php
sed -i "s/password_here/$DB_PASSWORD/"    /var/www/html/config.php

# 4. Mostrar en la página qué servidor la ha servido (para ver el balanceo)
sed -i 's|Demo app</p>|Demo app</p><p class="lead">Servidor: <strong><?php echo gethostname(); ?></strong></p>|' /var/www/html/index.php

# 5. Dar los ficheros al usuario de Apache
chown -R www-data:www-data /var/www/html

# 6. Reiniciar Apache
systemctl restart apache2
