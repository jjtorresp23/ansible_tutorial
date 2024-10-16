yum update -y


yum-config-manager --enable rhui-client-config-server-7
yum-config-manager --enable rhel-7-server-rhui-extras-rpms
yum -y install rh-amazon-rhui-client leapp-rhui-aws

yum -y install leapp-upgrade
