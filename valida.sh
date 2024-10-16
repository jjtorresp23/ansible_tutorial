for i in `cat inventory`
do
echo $i
ssh $i cat /etc/redhat-release
echo "------------------------------------------"
ssh $i crontab -l
echo "------------------------------------------"
ssh $i sudo grep sudo.log /etc/audit/audit.rules 
echo "------------------------------------------"
ssh $i sudo tail -3 /var/log/sudo.log
echo "------------------------------------------"
ssh $i sudo grep sha512 /etc/pam.d/password-auth
ssh $i sudo grep sha512 /etc/pam.d/system-auth
echo "------------------------------------------"
ssh $i sudo grep remember /etc/pam.d/system-auth
ssh $i sudo grep remember /etc/pam.d/password-auth
echo "------------------------------------------"
ssh $i sudo grep pwquality /etc/pam.d/password-auth
ssh $i sudo grep pwquality /etc/pam.d/system-auth 
echo "------------------------------------------"
ssh $i sudo grep -v "^#" /etc/security/pwquality.conf
echo "------------------------------------------"
ssh $i sudo grep -i Protocol /etc/ssh/sshd_config
echo "##########################################################################"
done
