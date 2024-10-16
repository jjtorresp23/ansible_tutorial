/usr/bin/cp /etc/ssh/sshd_config /etc/ssh/sshd_config-EnablingX11back
/usr/bin/perl -pi.back.sec.remediation -e 's/X11Forwarding no/X11Forwarding yes/g;' /etc/ssh/sshd_config
/usr/bin/systemctl restart sshd
