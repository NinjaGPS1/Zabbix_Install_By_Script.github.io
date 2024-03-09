#!/bin/bash
# By SOTHEA_GPS
# Selinux and Firewall turn off before run this

#Set Time
timedatectl set-timezone Asia/Phnom_Penh
timedatectl set-ntp 1

# Change hostname
#echo "192.168.x.x zabbix.domain" >> /etc/hosts
hostnamectl set-hostname zabbix-server

# Update && Upgrade Ubuntu
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl network-manager net-tools -y

sleep 3

#Install PHP for Zabbix
sudo apt install -y php php-{common,mysql,xml,xmlrpc,curl,gd,imagick,cli,dev,imap,mbstring,opcache,soap,zip,intl}
sudo apt install -y php php-{cgi,mbstring,net-socket,bcmath} libapache2-mod-php php-xml-util 

sleep 3

# Downloads Zabbix Repository
sudo wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-4%2Bubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.2-4+ubuntu22.04_all.deb
sudo apt update

sleep 3

# Zabbix Packages Install
sudo apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

sleep 3

# MariaDB Donwload and Install
# Version of MariaDB is Important
sudo apt update
sudo apt install software-properties-common -y
curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=10.7
sudo bash mariadb_repo_setup --mariadb-server-version=10.7
sudo apt update
sudo apt -y install mariadb-common mariadb-server mariadb-client
sudo systemctl enable mariadb
sudo systemctl start mariadb

sleep 3

# Configure Maria DB
# Type Y/n follow the question below
mysql_secure_installation <<EOF

y
y
zabbix
zabbix
y
y
y
y
EOF

mysql -u root -p <<EOF
create database zabbix character set utf8mb4 collate utf8mb4_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
set global log_bin_trust_function_creators = 1;
Flush Privileges;
EOF

sleep 3

# Get PHP for Zabbix
apt-cache policy zabbix-server-mysql

sleep 3

# Import Structure of Zabbix database
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p'zabbix' zabbix

# Configure DBHost, DBName, DBUser, DBPassword /etc/zabbix/zabbix_server.conf
#sed -i 's/# DBHost=localhost/DBHost=localhost/g' /etc/zabbix/zabbix_server.conf
#sed -i "s/DBName=zabbix/DBName=zabbix/g" /etc/zabbix/zabbix_server.conf
#sed -i "s/DBUser=zabbix/DBUser=zabbix/g" /etc/zabbix/zabbix_server.conf
sed -i 's/# DBPassword=/DBPassword=zabbix/g' /etc/zabbix/zabbix_server.conf

#Enable and restart Zabbix
sudo systemctl enable zabbix-server zabbix-agent apache2
sudo systemctl restart zabbix-server zabbix-agent apache2


sleep 3

# Allow Firewall Port Forward
sudo ufw allow proto tcp from any to any port 10050,10051,80,443,3000
echo "========================================================="
echo "=========================SOTHEA=========================="
echo "========================================================="
echo "========================GPS-TEAM========================="
echo "========================================================="
