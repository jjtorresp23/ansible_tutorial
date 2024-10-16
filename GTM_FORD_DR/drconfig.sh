#!/bin/bash
###
iipp=$(ifconfig -a|grep 10.130|awk '{print $2}')
ipdr=$(echo $iipp| cut -d"." -f1-2)
jname=X
fqdnn=$jname.tradesphere.net

if [ $ipdr == 10.130 ]; then
   date >> /var/log/drconfig.out
   echo "Starting DR Configuration.." >> /var/log/drconfig.out
   echo "--------------------------------------" >> /var/log/drconfig.out
## Deleting cron fo appadmin
   sudo -u appadmin crontab -l >> /tmp/cron-appadmin-dr.out
   sudo -u appadmin crontab -r
## Configuring hostname
   hostnamectl set-hostname $fqdnn
## Configuring /etc/hosts
   chattr -i /etc/hosts
   > /etc/hosts
   echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" >> /etc/hosts
   echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
   echo $iipp $fqdnn $jname >> /etc/hosts
   chattr +i /etc/hosts
## Updating /etc/resolv.conf
   chattr -i /etc/resolv.conf
   > /etc/resolv.conf
   echo "search ec2.internal tradesphere.net" > /etc/resolv.conf
   echo "nameserver 10.130.34.135" >> /etc/resolv.conf
   echo "nameserver 10.130.32.132" >> /etc/resolv.conf
   chattr +i /etc/resolv.conf
## Adding accounts for App Team
   useradd -c "Victor Vergara, AMS Team on DR" vvergaradr
   echo "vvergaradr    ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/appteamdr; chmod 440 /etc/sudoers.d/appteamdr
   usermod -p '$6$uj5jspmvgCVtHUcE$waaWJOssx0WIGt5WJ9S8O.Xfc7q78rTW7245pV8zwg2S6MjR2e0TXgSJdE8MyZYAS5PF6JXde8C4se/MG7QjU1' vvergaradr
  else
   date >> /var/log/drconfig.out
   echo "Not a DR scenario in progress, no changes were made to current configuration." >> /var/log/drconfig.out
   echo "--------------------------------------" >> /var/log/drconfig.out
fi
