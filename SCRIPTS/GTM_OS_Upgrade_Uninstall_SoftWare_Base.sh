
rpm -qa|grep -i mdatp-|xargs -i rpm -e {}
rpm -qa|grep -i check-mk-agent-|xargs -i rpm -e {}
rpm -qa|grep -i TaniumClient-|xargs -i rpm -e {}
rpm -qa|grep -i tet-sensor|xargs -i rpm -e {}
rpm -qa|grep -i falcon-sensor|xargs -i rpm -e {}
rpm -qa|grep -i splunkforwarder|xargs -i rpm -e {}
rpm -qa|grep -i mde-netfilter|xargs -i rpm -e {}
rpm -qa|grep -i amazon-ssm-agent|xargs -i rpm -e {}
rpm -qa|grep -i inspectorssmplugin|xargs -i rpm -e {}

rpm -qa|grep -i CentrifyDC |xargs -i rpm -e {}
rpm -qa|grep -i qualys-cloud-agent |xargs -i rpm -e {}


