#!/bin/bash

vol="/dev/$(sudo lsblk -o name,type,mountpoint,label,uuid | grep -v root | grep -v ephem | grep -v SWAP | grep -v vda | tail -1 | awk '{print $1}')"

sudo mkfs -t ext4 $vol
sudo mkdir /opt/apache_data
sudo mount $vol /opt/apache_data
echo "$vol /opt/apache_data ext4 defaults 0 1 " | sudo tee --append  /etc/fstab


sudo apt-get update
sudo apt-get install -y apache2 libapache2-mod-php5

sudo service apache2 stop

sudo rsync -av /var/www/html /opt/apache_data
sudo sed -i -e "s|var/www|opt/apache_data|g" /etc/apache2/sites-enabled/000-default.conf
sudo sed -i -e "s|var/www|opt/apache_data|g" /etc/apache2/sites-available/default-ssl.conf

sudo service apache2 restart
