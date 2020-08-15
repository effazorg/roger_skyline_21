#!/bin/bash
sudo touch /home/agita/cron_md5
sudo chmod 777 /home/agita/cron_md5
m1="$(md5sum '/etc/crontab' | awk '{print $1}')"
m2="$(cat '/home/agita/cron_md5')"
echo ${m1}
echo ${m2}

if [ "$m1" != "$m2" ] ; then
    md5sum /etc/crontabs | awk '{print $1}' > /home/agita/cron_md5
    echo "KO" | mails -s "Cronfile was changed" root@debian.lan
fi
