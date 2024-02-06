systemctl stop sssd
rm -rf /var/lib/sss/db/*
kdestroy
realm leave
rm -rf /etc/krb5.keytab
echo "(GaszJfu{yl*j+4E|MO_m>!=" | realm join lii01.livun.com -U msa_csandoval
authconfig --enablesssd --enablesssdauth --enablelocauthorize --enablemkhomedir --update
