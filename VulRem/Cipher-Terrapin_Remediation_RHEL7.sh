cp /etc/ssh/sshd_config /etc/ssh/sshd_configBackup
/usr/bin/sed -i '/# Ciphers/a\
Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com' /etc/ssh/sshd_config
/usr/bin/sed -i '/# Ciphers/a\
MACs umac-64@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512' /etc/ssh/sshd_config
cp /etc/ssh/ssh_config /etc/ssh/ssh_configBackup
/usr/bin/sed -i '/#   Ciphers/a\
Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com' /etc/ssh/ssh_config
/usr/bin/sed -i '/#   MACs/a\
MACs umac-64@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512' /etc/ssh/ssh_config
/usr/bin/systemctl restart sshd
