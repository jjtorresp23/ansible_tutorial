/usr/bin/cp /etc/ssh/sshd_config /etc/ssh/sshd_config-DisablingX11back
/usr/bin/perl -pi.back.sec.remediation -e 's/X11Forwarding yes/X11Forwarding no/g;' /etc/ssh/sshd_config
/usr/bin/systemctl restart sshd
