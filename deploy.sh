#!/bin/bash

# Can be run only with sudo User!

sudo apt-get update -y
sudo apt-get upgrade -y

# Install packages

sudo apt-get install net-tools -y
sudo apt-get install openssh-server -y
sudo apt-get install ufw -y
sudo apt-get install iptables -y
sudo apt-get install fail2ban -y
sudo apt-get install apache2 -y
sudo apt-get install portsentry -y
sudo apt-get install bsd-mailx -y
sudo apt-get install postfix -y
sudo apt-get install mutt -y

# Making static ip

cp ~/roger_skyline_21/deploy_src/interfaces /etc/network/interfaces
cp ~/roger_skyline_21/deploy_src/enp0s3 /etc/network/interfaces.d
cp ~/roger_skyline_21/deploy_src/enp0s8 /etc/network/interfaces.d

sudo service networking restart

# Changing ssh port

sudo sid -i 's/#Port 22/ Port 55000/' /etc/ssh/sshd_config

# Changing permit root login

sudo sid -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd/config
sudo service sshd restart

# Set ufw

sudo ufw enable
sudo ufw allow 55000/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443

# Set fail2ban

sudo cp ~/roger_skyline_21/deploy_src/jail.local /etc/fail2ban/
sudo cp ~/roger_skyline_21/deploy_src/http-get-dos.conf /etc/fail2ban/filter.d/
sudo ufw reload
sudo service fail2ban restart

# Set portsentry

sudo cp ~/roger_skyline_21/deploy_src/portsentry /etc/default/
sudo cp ~/roger_skyline_21/deploy_src/portsentry.conf /etc/portsentry/
sudo /etc/init.d/portsentry start

# Disable services

sudo systemctl disable bluetooth.service
sudo systemctl disable console-setup.service
sudo systemctl disable keybord-setup.service

# Job for crontab

sudo crontab -l > foocron
echo "0 4 * * MON ~/roger_skyline_21/deploy_src/i_will_update.sh &" >> foocron
echo "* * * * * ~/roger_skyline_21/deploy_src/i_will_monitor_cron.sh &" > foocron
sudo crontab foocron
rm foocron

# Set mail

sed -i 's/root:/root: root/' /etc/aliases
sudo newaliases
sudo postconf -e "home_mailbox = mail/"
sudo service postfix restart
sudo cp ~/roger_skyline_21/deploy_src/.muttrc /root

# SSL selfsigned key

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -subj "/C=RU/ST=/L=/O=/OU=/CN=192.168.56.101" \
     -keyout /etc/ssl/private/apache-selfsigned.key \
     -out /etc/ssl/certs/apache-selfsigned.crt
cp ~/roger_skyline_21/deploy_src/ssl-params.conf /etc/apache2/conf-available/
cp ~/roger_skyline_21/deploy_src/default-ssl.conf /etc/apache2/sites-available/
cp ~/roger_skyline_21/deploy_src/000-default.conf /etc/apache2/sites-available/
cp ~/roger_skyline_21/deploy_src/login.html /var/www/html/
sudo a2enmod ssl
sudo a2enmod headers
sudo a2ensite default-ssl
sudo a2enconf ssl-params
sudo apache2ctl configtest
sudo systemctl restart apache2
