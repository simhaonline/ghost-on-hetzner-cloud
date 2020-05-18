#!/bin/sh
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

DOMAIN=$1
EMAIL=$2

echo "16.1 Install Docker"
dnf -y install docker docker-compose
systemctl enable --now docker

echo "16.2 Install certbot"
dnf -y install certbot 

echo "16.3 Obtain certificates"
keyfile="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
if [ -e "$keyfile" ]
then
 	echo "Use existing keyfiles"
else
	certbot certonly --standalone --no-eff-email \
		--agree-tos --rsa-key-size 4096 --email ${EMAIL} \
		--domains ${DOMAIN},www.${DOMAIN},cms.${DOMAIN}
fi

echo "16.4 Install + enable nginx"
dnf -y install nginx
mv cms-ghost.conf /etc/nginx/conf.d/
systemctl enable --now nginx

echo "16.5 Start Ghost"
docker-compose up -d

echo '16.6 Simple tests'
ufw status
uname -a
docker version
systemctl status nginx
