for i in `cat inventory`
do
echo $i 
echo "/etc/ssh/sshd_config"
ssh $i sudo grep aes128 /etc/ssh/sshd_config|grep -v "^#"
ssh $i sudo grep umac /etc/ssh/sshd_config|grep -v "^#"
echo "/etc/ssh/ssh_config"
ssh $i sudo grep aes128 /etc/ssh/ssh_config|grep -v "^#"
ssh $i sudo grep umac /etc/ssh/ssh_config|grep -v "^#"
echo "###################################################"
done
