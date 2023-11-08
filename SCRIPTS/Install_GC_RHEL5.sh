export IS_OFFLINE_PACKAGE=true
export SSL_SERVER="34.29.175.246"
export UI_UM_PASSWORD="WaHSnWPw"
export GC_PROFILE='default'
rpm -i /tmp/gc-guest-agent-x86_64-polling-rhel4.rpm
export CUSTOM_GC_ROOT=/custom_path
export GC_ROOT=/custom_path
export CUSTOM_GC_MAN_DIR=/custom_man_path
rpm -i /tmp/gc-guest-agent-x86_64-polling-rhel4.rpm --relocate /var/lib/guardicore=/custom_path --relocate /usr/local/share/man=/custom_man_path
