#systemctl stop sssd
#rm -rf /var/lib/sss/db/*
#kdestroy
#realm leave
#rm -rf /etc/krb5.keytab
#echo "July10LR2@24" | realm join dev.liiaws.net -U dmc_lrovman
#authconfig --enablesssd --enablesssdauth --enablelocauthorize --enablemkhomedir --update
