#!/bin/bash
# Capa 1: obtiene un certificado de Let's Encrypt con Certbot y activa HTTPS

# Muestra cada orden y para si alguna falla
set -ex

# Cargamos las variables
source /vagrant/scripts/.env
export DEBIAN_FRONTEND=noninteractive

# 0. Si no hay token de DuckDNS, no se puede pedir el certificado
if [ -z "$DUCKDNS_TOKEN" ]; then
  echo "AVISO: falta scripts/duckdns_token.txt. Se omite HTTPS."
  exit 0
fi

# 1. Instalar Certbot, su plugin para Apache y el plugin de DuckDNS
#    (en un entorno virtual de Python, como indica la documentación de Certbot)
apt-get update
apt-get install -y python3-venv python3-dev gcc 
apt-get install -y libaugeas0 libaugeas-dev libffi-dev
rm -rf /opt/certbot
python3 -m venv /opt/certbot
/opt/certbot/bin/pip install --upgrade pip
/opt/certbot/bin/pip install certbot certbot-apache certbot-dns-duckdns
ln -sf /opt/certbot/bin/certbot /usr/bin/certbot

# 2. Pedir el certificado validando el dominio por DNS (DuckDNS)
#    y configurarlo en Apache, redirigiendo HTTP a HTTPS
certbot run \
  --non-interactive \
  --agree-tos \
  --email "$LE_EMAIL" \
  --preferred-challenges dns \
  --authenticator dns-duckdns \
  --dns-duckdns-token "$DUCKDNS_TOKEN" \
  --dns-duckdns-propagation-seconds 60 \
  --installer apache \
  --redirect \
  -d "$DOMAIN"
