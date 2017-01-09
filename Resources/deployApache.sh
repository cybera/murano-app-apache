#!/bin/bash

vol="/dev/$(lsblk -o name,type,mountpoint,label,uuid | grep -v root | grep -v ephem | grep -v SWAP | grep -v vda | tail -1 | awk '{print $1}')"

mkfs -t ext4 $vol
mkdir /opt/apache_data
mount $vol /opt/apache_data
echo "$vol /opt/apache_data ext4 defaults 0 1 " |  tee --append  /etc/fstab

if (python -mplatform | grep -qi Ubuntu)
then #Ubuntu
  apt-get update
  apt-get install -y apache2 libapache2-mod-php5

  service apache2 stop

  rsync -av /var/www/html /opt/apache_data
  sed -i -e "s|var/www|opt/apache_data|g" /etc/apache2/sites-enabled/000-default.conf
  sed -i -e "s|var/www|opt/apache_data|g" /etc/apache2/sites-available/default-ssl.conf
  sed -i -e "s|var/www|opt/apache_data|g" /etc/apache2/apache2.conf

  sudo service apache2 restart
else #CentOS
  yum clean all
  yum -y  update
  yum -y install httpd mod_ssl
  rsync -av /var/www/html /opt/apache_data
  sed -i -e "s|var/www|opt/apache_data|g" /etc/httpd/conf/httpd.conf
  service httpd restart

fi

