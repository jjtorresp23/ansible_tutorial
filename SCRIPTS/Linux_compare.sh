#!/bin/bash
#
#  Owner: Linux Team
#

DEBUG="0"
VERBOSE="1"
SNAPHIST="53"
RUN_DIR="/var/UNIX"
LOG_FILE="/var/log/server_config_snapshot"
CONFFILE=$(echo "${LOCATION}.conf" | sed "s:\.k*sh.conf$:.conf:") 

[ ! "$(uname)" = "Linux" ] && { echo "Sorry, $(uname) is not supported for now, only Linux is." >&2; exit 1; }
[ ! "$(ps -p $PPID -o comm | tail -1)" = "bash" -o ! "$(tty | grep 'not a tty')" = "" ] && COLORS93='.\[[0-9;]*m' || COLORS93="COLORS93"

msg()
{
 [[ $VERBOSE = 0 ]] && return 0
 SPACE=21
 case "$1" in
  "-d") printf "%-${SPACE}s :   %s\n" "$(date '+%Y/%m/%d %H:%M:%S')" "$(echo $2)" ;;
  "-e") printf "\E[5;31;40m%${SPACE}s\E[0m :   \E[4m%s\E[0m \E[1m%s\E[0m\n" "! ! ! ERROR ! ! !" "$2" "$(echo $3)" ;;
  "-w") printf "\E[1;35;40m%${SPACE}s\E[0m :   \E[4m%s\E[0m \E[1m%s\E[0m\n" "Warning" "$2" "$(echo $3)" ;;
  "-s") printf "\E[1;32;40m%${SPACE}s\E[0m :   \E[4m%s\E[0m \E[1m%s\E[0m\n" "Success" "$2" "$(echo $3)" ;;
  "-i") printf "\E[1m%${SPACE}s\E[0m :   %s\n" "$2" "$(echo $3)" ;;
  *)    case "$2" in
  "OK")  printf "%${SPACE}s :\E[1;32;40m %s\E[0m\n" "$1" "$2" ;;
  "KO")  printf "%${SPACE}s :\E[1;31;40m %s\E[0m                              \E[1;31;40m<<<=========\E[0m\n\n" "$1" "$2" ;;
  "OLD") echo "$3" | while read TEXT; do printf "\E[0;35;40m%${SPACE}s\E[0m :\E[0;34;40m%s\E[0m: %s\n" "$1" "OLD" "$(echo $TEXT)"; done ;;
  "NEW") echo "$3" | while read TEXT; do printf "\E[1;35;40m%${SPACE}s\E[0m :\E[1;34;40m%s\E[0m: %s\n" "$1" "NEW" "$(echo $TEXT)"; done ;;
  "N/A") printf "%${SPACE}s :\E[1;33;40m%s\E[0m\n" "$1" "$(echo $2)" ;;
  *)     printf "%${SPACE}s : %s\n" "$1" "$(echo $2)" ;;
  esac ;;
 esac |sed "s:${COLORS93}::g"
}

pGrep()
{
 GEXP="$1"
 GFIL="$2"
 ARGS="$3"
 GEXP=$(echo "$GEXP" | sed "s/^\^/###BOL###/")
 GEXP=$(echo "$GEXP" | sed "s/\$$/###EOL###/")
 cat $GFIL | sed -e 's/^/###BOL###/g' -e 's/$/###EOL###/g' | tr -d "\n" | sed "s/###EOL######BOL######EOL###/###EOL###\n/g" \
 | grep $ARGS "$GEXP" | sed -e 's/###BOL###//g' | perl -pe 's/###EOL###/\n/g'
}

copy()
{
 if [ ! $# -eq 2 ]; then
  msg -w "Copy: Cannot handle provided parameters:" "$@"
 elif [ -f "$1" ]; then
  cp "$1" "$2"
 else
  msg -w "Copy: File not found:" "'$1'"
 fi
}

rotate_file()
{
 for F in $@; do
  test -f ${F} || continue
  V=$SNAPHIST
  while [ $V -gt 0 ]; do
   test -f ${F}.${V} && mv ${F}.${V} ${F}.$(($V+1))
   V=$(($V-1))
  done
   test -f ${F} && mv ${F} ${F}.1
  done
}

rotate_log()
{
 if [ ! -f $1 ]; then
  touch $1
 elif [ $(wc -l < $1) -gt 250000 ]; then
  [ -f ${1}.2.gz ] && mv -f ${1}.2.gz ${1}.3.gz
  [ -f ${1}.1.gz ] && mv -f ${1}.1.gz ${1}.2.gz
  gzip -c ${1} > ${1}.1.gz
  > ${1}
 fi
}

gather_info()
{
     [ ! "$1" = "" -a -d "$1" ] && cd "$1"
     msg -d "Creating system information snapshot."
     DIR=configuration_$(uname -n | cut -f1 -d.)
     LOG_DIR=/tmp/${DIR}
     WHOAMI=$(whoami)
     mkdir -p $RUN_DIR
     test -d $RUN_DIR || { msg -e "'$RUN_DIR' directory is NOT created." "Gathering server configuration exited!"; exit 1; }
     touch ${RUN_DIR}/testfile || { msg -e "'$RUN_DIR' directory is NOT writable." "Gathering server configuration exited!"; exit 1; }
     rm ${RUN_DIR}/testfile
     mkdir -p $LOG_DIR
     test -d $LOG_DIR || { msg -e "'$LOG_DIR' directory is not created." "Gathering server configuration exited!"; exit 1; }
     touch ${LOG_DIR}/testfile || { msg -e "'$LOG_DIR' directory is NOT writable." "Gathering server configuration exited!"; exit 1; }
     rm ${LOG_DIR}/testfile
     date | awk '{print $5}' > $LOG_DIR/timezone
     cat /etc/resolv.conf > $LOG_DIR/ETC_resolv_conf
     who -r | awk '{print $1" "$2}' > $LOG_DIR/ETC_runlevel
     uname -a > $LOG_DIR/uname-a
     for F in $(ls /etc/*-release); do
          echo === $F =================================
          cat $F | sed "s/^ *$/#/g"
          echo
     done > $LOG_DIR/ETC_release
     rpm -qa > $LOG_DIR/rpm-qa
     rpm -Va --nosize --nofiledigest --nomtime > $LOG_DIR/rpm-Va 2>/dev/null || rpm -Va --nosize --nomd5 --nomtime > $LOG_DIR/rpm-Va 2>/dev/null
     uptime > $LOG_DIR/uptime

     [ -x /usr/sbin/dmidecode ] && dmidecode > $LOG_DIR/dmidecode
     lsmod > $LOG_DIR/lsmod
     lspci -vv > $LOG_DIR/lspci-vv
     cat /proc/scsi/scsi > $LOG_DIR/PROC_scsi
     for M in $(lsmod | awk '{print $1}' | grep -v "^Module"); do
          echo === $M =================================
          modinfo $M 2>&1 | sed "s/^ *$/#/g"
          echo
     done > $LOG_DIR/modinfo

     [ "$WHOAMI" = "root" ] && [ -f /boot/grub/menu.lst ] && copy /boot/grub/menu.lst $LOG_DIR/BOOT_grub

     if [ -x /sbin/lvm ]; then
          [ "$WHOAMI" = "root" ] && pvdisplay -m > $LOG_DIR/pvdisplay-m
          [ "$WHOAMI" = "root" ] && vgdisplay -v > $LOG_DIR/vgdisplay-v
          [ "$WHOAMI" = "root" ] && lvdisplay -m > $LOG_DIR/lvdisplay-m
     fi
     [ "$WHOAMI" = "root" ] && for D in $(ls /dev/hd*[a-z] /dev/sd*[a-z] 2>/dev/null); do
          echo === $D =================================;
          fdisk -l $D | sed "s/^ *$/#/g"
          echo
     done > $LOG_DIR/fdisk-l

     free > $LOG_DIR/free
     ipcs -a > $LOG_DIR/ipcs-a
     ps -eo vsz,pid,comm > $LOG_DIR/ps-eo_vsz

     mount | grep -w -E "ext[234]|nfs|xfs"> $LOG_DIR/mount
     df -vm > $LOG_DIR/df-m
     copy /etc/fstab $LOG_DIR/ETC_fstab
     for FS in $(mount | grep -w -E "ext[234]|nfs|xfs" | awk '{print $3}'); do ls -ld "$FS"; done > $LOG_DIR/ls-ld_FS

     ifconfig -a > $LOG_DIR/ifconfig-a
     netstat -rn > $LOG_DIR/netstat-rn
     netstat -lntp > $LOG_DIR/netstat-lntp 2>&1
     netstat -lnup > $LOG_DIR/netstat-lnup 2>&1
     [ "$WHOAMI" = "root" ] && iptables -L -n > $LOG_DIR/iptables-L
     [ "$WHOAMI" = "root" ] && [ -f /etc/sysconfig/iptables ] && copy /etc/sysconfig/iptables $LOG_DIR/ETC_iptables
     [ "$WHOAMI" = "root" ] && /bin/systemctl status firewalld.service > $LOG_DIR/firewalld
     copy /etc/hosts $LOG_DIR/ETC_hosts
     for I in $(ifconfig -a | grep "^[a-z]" | awk '{print $1}'); do
          echo === $I =================================;
          ethtool $I 2>&1 | sed "s/^ *$/#/g"
          echo
     done > $LOG_DIR/ethtool
     for I in $(ifconfig -a | grep "^[a-z]" | awk '{print $1}'); do
          echo === $I =================================;
          test -f /etc/sysconfig/network-scripts/ifcfg-${I} && cat /etc/sysconfig/network-scripts/ifcfg-${I} | sed "s/^ *$/#/g"
          echo
     done > $LOG_DIR/ETC_ifcfg

     [ -f /etc/exports ] && copy /etc/exports $LOG_DIR/NFS_exports
     [ "$WHOAMI" = "root" ] && exportfs > $LOG_DIR/NFS_exportfs
     showmount -a > $LOG_DIR/NFS_showmount-a 2>&1

     copy /etc/passwd $LOG_DIR/ETC_passwd
     copy /etc/inittab $LOG_DIR/ETC_inittab
     copy /etc/group $LOG_DIR/ETC_group
     [ "$WHOAMI" = "root" ] && copy /etc/shadow $LOG_DIR/ETC_shadow
     [ "$WHOAMI" = "root" ] && copy /etc/sudoers $LOG_DIR/ETC_sudoers
     copy /etc/hosts $LOG_DIR/ETC_hosts
     [ -f /etc/syslog.conf ] && copy /etc/syslog.conf $LOG_DIR/ETC_syslog_conf
     [ -f /etc/rsyslog.conf ] && copy /etc/rsyslog.conf $LOG_DIR/ETC_rsyslog_conf
     [ -f /etc/mail/sendmail.cf ] && copy /etc/mail/sendmail.cf $LOG_DIR/ETC_mail_sendmail.cf

     ps -ef > $LOG_DIR/ps-ef

     dmesg > $LOG_DIR/dmesg
     crontab -l > $LOG_DIR/crontab-l
     [ "$WHOAMI" = "root" ] && for U in $(ls /var/spool/cron/ | grep -w -v "root"); do
          if /usr/bin/id $U >/dev/null 2>&1; then
               echo === $U =================================
               cat /var/spool/cron/$U | sed "s:^ *$:#:g"
               echo
          fi
     done > $LOG_DIR/crontab-l_user

     rotate_file ${RUN_DIR}/*.tgz
     tar -cf - -C $LOG_DIR/.. ./${DIR} | gzip -c > ${RUN_DIR}/${DIR}.tgz
     chmod 644 ${RUN_DIR}/${DIR}.tgz

     msg -d "Done creating system information snapshot."

     if [ -s ${RUN_DIR}/${DIR}.tgz ]; then
          test -d ${LOG_DIR} && rm -f ${LOG_DIR}/* && rmdir $LOG_DIR
          msg -s "Server configuration were collected."
     else
          msg -e "Unable to gather server configuration."
     fi
}

display_history()
{
     T=0
     for F in $(ls -t ${RUN_DIR}/*.tgz* | sort -n -k3 -t.); do
          HISTORY[$T]=$F
          T=$(($T+1))
     done
     while [ $T -gt 0 ]; do
          T=$(($T-1))
          if [ "$2" = "" -o "$1" = "$T" -o "$2" = "$T" ]; then
               HISTDATE[$T]=$(gunzip -c < ${HISTORY[$T]} | tar -tvf - | head -1 | awk '{print $4 "_" $5 }')
               msg $T "${HISTDATE[$T]} : ${HISTORY[$T]}"
          fi
     done
}

get_diff()
{
     [[ $DEBUG -eq 1 ]] && set -x
     F=$1
     NEW=$2
     OLD=$3
     RC=0

    case $1 in
    "ps-ef")
     NEW_VAR=$(grep "^[^ ][^ ]*  *[0-9][0-9]*  *1 " $NEW | awk '{print $8}' | sort -u)
     OLD_VAR=$(grep "^[^ ][^ ]*  *[0-9][0-9]*  *1 " $OLD | awk '{print $8}' | sort -u)
     VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
     [ ! "$VAR" = "" ] && { msg -w "Processes NOT running now:" "$VAR"; RC=1; }
     VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
     [ ! "$VAR" = "" ] && { msg -w "Processes that were NOT running before:" "$VAR"; RC=1; }
     ;;
     "free")
     NEW_VAR=$(grep -w "^Mem:" $NEW | awk '{print $2}')
     OLD_VAR=$(grep -w "^Mem:" $OLD | awk '{print $2}')
     [[ "$NEW_VAR" = "$OLD_VAR" ]] || { msg -w "Memory size is different:" "Old: $OLD_VAR / New: $NEW_VAR"; RC=1; }
     NEW_VAR=$(grep -w "^Swap:" $NEW | awk '{print $2}')
     OLD_VAR=$(grep -w "^Swap:" $OLD | awk '{print $2}')
     [[ "$NEW_VAR" = "$OLD_VAR" ]] || { msg -w "Swap size is different:" "Old: $OLD_VAR / New: $NEW_VAR"; RC=1; }
     ;;
     "ifconfig-a")
      for VAR in $(cat $NEW $OLD | grep "^[a-zA-Z]" | awk '{print $1}' | sort -u); do
      OLD_VAR=$(pGrep "^$VAR " $OLD | head -1 | awk '{print $5}')
      NEW_VAR=$(pGrep "^$VAR " $NEW | head -1 | awk '{print $5}')
      if [[ ! "$OLD_VAR" = "$NEW_VAR" ]]; then
        msg -w "MAC address has changed for $VAR:" "Old:$OLD_VAR / New:$NEW_VAR";
        RC=1
      fi
      OLD_VAR=$(pGrep "^$VAR " $OLD | grep "inet") # | awk '{print $1 " " $2 " " $4}')
      NEW_VAR=$(pGrep "^$VAR " $NEW | grep "inet") # | awk '{print $1 " " $2 " " $4}')
      if [[ ! "$OLD_VAR" = "$NEW_VAR" ]]; then
        msg -w "Network interface configuration changed for:" "$VAR"
        [[ "$OLD_VAR" = "" ]] || msg "$F" "OLD" "$OLD_VAR"
        [[ "$NEW_VAR" = "" ]] || msg "$F" "NEW" "$NEW_VAR"
        RC=1
      fi
    done
    ;;
    "netstat-rn")
     NEW_VAR=$(grep -w -v "Flags" $NEW | awk '{print "Route:"$1 " GW:" $2 " NM:" $3 " IF:" $8}')
     OLD_VAR=$(grep -w -v "Flags" $OLD | awk '{print "Route:"$1 " GW:" $2 " NM:" $3 " IF:" $8}')
     VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
     [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR"; RC=1; }
     VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
     [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR"; RC=1; }
     ;;
    "ethtool")
     for D in $(grep "^Settings for" $NEW $OLD | cut -f3 -d\ | sort -u); do
      NEW_VAR=$(pGrep $D $NEW)
      OLD_VAR=$(pGrep $D $OLD)
      if [ ! "$OLD_VAR" = "$NEW_VAR" ]; then
        msg -w "Network interface settings have changed on:" "$D"
        VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
        [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR"; RC=1; }
        VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
        [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR"; RC=1; }
      fi
     done
     ;;
    "ETC_ifcfg")
     for I in $(grep "^=== " $NEW $OLD | cut -f2 -d\  | sort -u); do
      NEW_VAR=$(pGrep "^=== $I ===" $NEW)
      OLD_VAR=$(pGrep "^=== $I ===" $OLD)
      if [ ! "$OLD_VAR" = "$NEW_VAR" ]; then
        msg -w "Network interface configuration has changed for:" "$I"
        VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
        [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR"; RC=1; }
        VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
        [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR"; RC=1; }
      fi
     done
     ;;
    "iptables-L")
    for I in $(grep "^Chain " $NEW $OLD | cut -f2 -d\ ); do
      NEW_VAR=$(pGrep "^Chain $I " $NEW)
      OLD_VAR=$(pGrep "^Chain $I " $OLD)
      if [ ! "$OLD_VAR" = "$NEW_VAR" ]; then
        msg -w "Firewall configuration has changed in chain:" "$I"
        VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
        [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR"; RC=1; }
        VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
        [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR"; RC=1; }
      fi
    done
    ;;
    "firewalld")
     NEW_VAR=$(grep Active $NEW | awk '{print $2}')
     OLD_VAR=$(grep Active $OLD | awk '{print $2}')
     VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
     [ ! "$VAR" = "" ] && { msg -w "Processes status before:" "$VAR"; RC=1; }
     VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
     [ ! "$VAR" = "" ] && { msg -w "Processes status now:" "$VAR"; RC=1; }
    ;;
    "lspci-vv")
     NEW_VAR=$(grep "^[0-9]" $NEW) # | tr '[]' '||')
     OLD_VAR=$(grep "^[0-9]" $OLD) # | tr '[]' '||')
     VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
     [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR"; RC=1; }
     VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
     [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR"; RC=1; }
    ;;
    "PROC_scsi")
     NEW_VAR=$(grep "^  Vendor:" $NEW)
     OLD_VAR=$(grep "^  Vendor:" $OLD)
     VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
     [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR"; RC=1; }
     VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
     [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR"; RC=1; }
    ;;
    "rpm-qa")
     NEW_VAR=$(cat $NEW | cut -f1 -d. | sort)
     OLD_VAR=$(cat $OLD | cut -f1 -d. | sort)
     VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
     [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR"; RC=1; }
     VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
     [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR"; RC=1; }
    ;;
    "lsmod")
    NEW_VAR=$(cat $NEW | awk '{print $1}' | sort)
    OLD_VAR=$(cat $OLD | awk '{print $1}' | sort)
    VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
    [ ! "$VAR" = "" ] && { msg -w "Kernel modules NOT loaded now:" "$VAR"; RC=1; }
    VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
    [ ! "$VAR" = "" ] && { msg -w "Kernel modules that were NOT loaded before:" "$VAR"; RC=1; }
    ;;
    "mount")
    for FS in $(cat $NEW | awk '{print $3}'); do
      cat $NEW | awk '{print $3}' | grep "^${FS}" | while read VAR; do
        [ "$VAR" = "$FS" ] && break
        [ "${VAR%/*}" = "${FS%/*}" ] && continue
        msg -w "$VAR is mounted before $FS"
        RC=1
      done
    done
    NEW_VAR=$(cat $NEW | awk '{print $3}')
    OLD_VAR=$(cat $OLD | awk '{print $3}')
    for VAR in $NEW_VAR; do
      echo "$OLD_VAR" | grep -q "^$VAR$" || \
      { msg -w "Filesystem mounted now but NOT mounted before:" "$VAR"; RC=1; }
    done
    for VAR in $OLD_VAR; do
      echo "$NEW_VAR" | grep -q "^$VAR$" || \
      { msg -w "Filesystem NOT mounted now but mounted before:" "$VAR"; RC=1; }
    done
    ;;
    "ETC_fstab")
    for FS in $(grep -v "^#" $NEW | awk '{print $2}' | sort -r); do
      VAR=$(grep -v "^#" $NEW | awk '{print $2}' | grep -w "^${FS}" | head -1)
      if [ ! "${FS}" = "$VAR" ]; then
        msg -w "'$VAR' will be mounted before '$FS'"
        RC=1
      fi
    done
    for FS in $(grep -v "^#" $NEW | grep "noauto" | awk '{print $2}'); do
      msg -w "FS is NOT mounted automatically:" "${FS}"
      RC=1
    done
    NEW_VAR=$(grep -v "^#" $NEW | awk '{print $2}')
    OLD_VAR=$(grep -v "^#" $OLD | awk '{print $2}')
    for VAR in $NEW_VAR; do
      echo "$OLD_VAR" | grep -q "^$VAR$" || \
      { msg -w "Filesystem NOT present before:" "$VAR"; RC=1; }
    done
    for VAR in $OLD_VAR; do
      echo "$NEW_VAR" | grep -q "^$VAR$" || \
      { msg -w "Filesystem NOT present now:" "$VAR"; RC=1; }
    done
    ;;
    "fdisk-l")
    for D in $(grep "^Disk /dev/" $NEW $OLD | cut -f2 -d\ | sort -u); do
      NEW_VAR=$(pGrep $D $NEW | grep -v "^#")
      OLD_VAR=$(pGrep $D $OLD | grep -v "^#")
      if [ ! "$OLD_VAR" = "$NEW_VAR" ]; then
        msg -w "Disk attributes have changed for:" "$D"
        VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR" | sed "s/\*/A/g")
        [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR"; RC=1; }
        VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR" | sed "s/\*/A/g")
        [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR"; RC=1; }
      fi
    done
    ;;
    "pvdisplay-m")
    for D in $(grep "PV Name" $NEW $OLD | awk '{print $3}' | sort -u); do
      NEW_VAR=$(pGrep $D $NEW)
      OLD_VAR=$(pGrep $D $OLD)
      if [ ! "$OLD_VAR" = "$NEW_VAR" ]; then
        msg -w "Physical volume has changed:" "$D"
        VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
        [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR"; RC=1; }
        VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
        [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR"; RC=1; }
      fi
    done
    ;;
    "lvdisplay-m")
    for D in $(grep "Logical volume" $NEW $OLD | awk '{print $3}' | sort -u); do
      NEW_VAR=$(pGrep $D $NEW)
      OLD_VAR=$(pGrep $D $OLD)
      if [ ! "$OLD_VAR" = "$NEW_VAR" ]; then
        msg -w "Logical volume has changed:" "$D"
        VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
        [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR"; RC=1; }
        VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
        [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR"; RC=1; }
      fi
    done
    ;;
    "vgdisplay-v")
    for D in $(grep "Volume group" $NEW $OLD | awk '{print $3}' | sort -u); do
      NEW_VAR=$(pGrep $D $NEW)
      OLD_VAR=$(pGrep $D $OLD)
      if [ ! "$OLD_VAR" = "$NEW_VAR" ]; then
        msg -w "Volume group has changed:" "$D"
        VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
        [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR"; RC=1; }
        VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
        [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR"; RC=1; }
      fi
    done
    ;;
    "ls-ld_FS")
    NEW_VAR=$(cat $NEW | awk '{print $9}')
    OLD_VAR=$(cat $OLD | awk '{print $9}')
    for FS in $(echo "$NEW_VAR" | grep -w "$OLD_VAR"); do
      NEW_P=$(grep " $FS$" $NEW | awk '{print $1}')
      NEW_U=$(grep " $FS$" $NEW | awk '{print $3}')
      NEW_G=$(grep " $FS$" $NEW | awk '{print $4}')
      OLD_P=$(grep " $FS$" $OLD | awk '{print $1}')
      OLD_U=$(grep " $FS$" $OLD | awk '{print $3}')
      OLD_G=$(grep " $FS$" $OLD | awk '{print $4}')
      if [ "$NEW_P" = "" ]; then
        msg -w "Removed filesystem:" "$FS"
      elif [ "$OLD_P" = "" ]; then
        msg -w "New filesystem:" "$FS"
      else
        [ "$NEW_P" = "$OLD_P" ] || { msg -w "FS permisions changed for '$FS':" "Old: $OLD_P / New: $NEW_P"; RC=1; }
        [ "$NEW_U" = "$OLD_U" ] || { msg -w "FS owner changed for '$FS':" "Old: $OLD_U / New: $NEW_U"; RC=1; }
        [ "$NEW_G" = "$OLD_G" ] || { msg -w "FS group changed for '$FS':" "Old: $OLD_G / New: $NEW_G"; RC=1; }
      fi
    done
    ;;
    "ETC_rsyslog_conf"|"ETC_inittab"|"ETC_sudoers"|"ETC_release"|"ETC_iptables")
    diff $NEW $OLD >/dev/null 2>&1
    if [ ! $? -eq 0 ]; then
      VAR=$(diff $NEW $OLD | grep "^>" | cut -c3- | grep -v "^#" | sort)
      [ ! "$VAR" = "" ] && msg "$F" "OLD" "$VAR" && RC=1
      VAR=$(diff $OLD $NEW | grep "^>" | cut -c3- | grep -v "^#" | sort)
      [ ! "$VAR" = "" ] && msg "$F" "NEW" "$VAR" && RC=1
    fi
    ;;
    "ETC_passwd")
    NEW_VAR=$(cat $NEW | cut -f1 -d:)
    OLD_VAR=$(cat $OLD | cut -f1 -d:)
    VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
    [ ! "$VAR" = "" ] && { msg -w "Removed user(s):" "$VAR"; RC=1; }
    VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
    [ ! "$VAR" = "" ] && { msg -w "New user(s):" "$VAR"; RC=1; }
    ;;
    "ETC_group")
    NEW_VAR=$(cat $NEW | cut -f1 -d:)
    OLD_VAR=$(cat $OLD | cut -f1 -d:)
    VAR=$(echo "$OLD_VAR" | grep -w -v "$NEW_VAR")
    [ ! "$VAR" = "" ] && { msg -w "Removed group(s):" "$VAR"; RC=1; }
    VAR=$(echo "$NEW_VAR" | grep -w -v "$OLD_VAR")
    [ ! "$VAR" = "" ] && { msg -w "New group(s):" "$VAR"; RC=1; }
    ;;
    "ETC_hosts")

    NEW_VAR=$(grep -v "^#" $NEW | awk '{print $1}' | sort -u | grep -v "^$")
    OLD_VAR=$(grep -v "^#" $OLD | awk '{print $1}' | sort -u | grep -v "^$")
    VAR=$(echo "$OLD_VAR" | grep -w -v "$NEW_VAR")
    [ ! "$VAR" = "" ] && { msg -w "Removed IP(s):" "$VAR"; RC=1; }
    VAR=$(echo "$NEW_VAR" | grep -w -v "$OLD_VAR")
    [ ! "$VAR" = "" ] && { msg -w "New IP(s):" "$VAR"; RC=1; }

    for VAR in $(grep -v "^#" $NEW $OLD | cut -f2- -d: | cut -f1 -d'#' | awk '{print $2 " " $3 " " $4 " " $5}' | sort -u); do
      NEW_VAR=$(grep -w $VAR $NEW | awk '{print $1}' | grep -v "^#")
      OLD_VAR=$(grep -w $VAR $OLD | awk '{print $1}' | grep -v "^#")
      if [ "$NEW_VAR" = "" ]; then
        msg "$F" "OLD" "$OLD_VAR $VAR"
        RC=1
      elif [ "$OLD_VAR" = "" ]; then
        msg "$F" "NEW" "$NEW_VAR $VAR"
        RC=1
      elif [ ! "$NEW_VAR" = "$OLD_VAR" ]; then
        msg -w "Hostname '$VAR' has different IP(s):" "Old: $OLD_VAR / New: $NEW_VAR"
        RC=1
      fi
    done
    ;;
    "uname-a")
    diff $NEW $OLD >/dev/null 2>&1
    if [ ! $? -eq 0 ]; then
      VAR=$(diff $NEW $OLD | grep "^>" | cut -c3-)
      [ ! "$VAR" = "" ] && msg "$F" "OLD" "$VAR"
      VAR=$(diff $OLD $NEW | grep "^>" | cut -c3-)
      [ ! "$VAR" = "" ] && msg "$F" "NEW" "$VAR"
      RC=1
    fi
    ;;
    "NFS_exports"|"NFS_exportfs")
    OLD_VAR=$(grep -v "^#" $OLD | awk '{print $1}')
    NEW_VAR=$(grep -v "^#" $NEW | awk '{print $1}')
    for VAR in $OLD_VAR; do
      echo "$NEW_VAR" | grep -q -w "^$VAR$" || \
      { msg $F "OLD" "$VAR"; RC=1; }
    done
    for VAR in $NEW_VAR; do
      echo "$OLD_VAR" | grep -q -w "^$VAR$" || \
      { msg $F "NEW" "$VAR"; RC=1; }
    done
    for FS in $(cat $NEW | awk '{print $1}'); do
      if cat $OLD | awk '{print $1}' | grep -q -w "^${FS}$"; then
        
	NEW_VAR=$(cat $NEW | grep -w "^$FS " | tr "," "\n" | grep "access=" | cut -f2 -d= | tr ":" "\n")
        OLD_VAR=$(cat $OLD | grep -w "^$FS " | tr "," "\n" | grep "access=" | cut -f2 -d= | tr ":" "\n")
        VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
        [ ! "$VAR" = "" ] && { msg -w "FS '$FS' was NOT exported to:" "$(echo $VAR)"; RC=1; }
        VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
        [ ! "$VAR" = "" ] && { msg -w "FS '$FS' is NOT anymore exported to:" "$(echo $VAR)"; RC=1; }
        
	NEW_VAR=$(cat $NEW | grep -w "^$FS " | tr ",:" "\n " | grep "root=" | cut -f2 -d=)
        OLD_VAR=$(cat $OLD | grep -w "^$FS " | tr ",:" "\n " | grep "root=" | cut -f2 -d=)
        VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
        [ ! "$VAR" = "" ] && { msg -w "NFS Root access to '$FS' is NOT anymore valid for:" "$(echo $VAR)" ; RC=1; }
        VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
        [ ! "$VAR" = "" ] && { msg -w "NFS ROOT access to '$FS' was NOT valid for:" "$(echo $VAR)"; RC=1; }
        
	NEW_VAR=$(cat $NEW | grep -w "^$FS " | tr ",:" "\n " | grep "sec=" | cut -f2 -d=)
        OLD_VAR=$(cat $OLD | grep -w "^$FS " | tr ",:" "\n " | grep "sec=" | cut -f2 -d=)
        VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
        [ ! "$VAR" = "" ] && { msg -w "NFS Security setting of '$FS' is NOT anymore:" "$(echo $VAR)" ; RC=1; }
        VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
        [ ! "$VAR" = "" ] && { msg -w "NFS Security setting of '$FS' was NOT :" "$(echo $VAR)"; RC=1; }
      fi
    done
    ;;
    "crontab-l")
    VAR=$(diff $NEW $OLD | grep "^>" | cut -c3- | grep -v "^#" | tr "*" '%')
    [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR" | tr '%' '*'; RC=1; }
    VAR=$(diff $OLD $NEW | grep "^>" | cut -c3- | grep -v "^#" | tr "*" '%')
    [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR" | tr '%' '*'; RC=1; }
    ;;
    "crontab-l_user")
    for VAR_U in $(grep "^=== " $OLD $NEW | awk '{print $2}' | sort -u); do
      NEW_VAR=$(grep -v "^#" $NEW | sed "s/^=== /%=== /g" | tr "%" "\n" | pGrep "^=== ${VAR_U}" | tr '*' '%')
      OLD_VAR=$(grep -v "^#" $OLD | sed "s/^=== /%=== /g" | tr "%" "\n" | pGrep "^=== ${VAR_U}" | tr '*' '%')
      if [ "$NEW_VAR" = "" -a ! "$OLD_VAR" = "" ]; then
        msg -w "Crontab removed for user:" "${VAR_U}"
        msg $F "OLD" "$OLD_VAR" | tr '%' '*'; RC=1;
      elif [ "$OLD_VAR" = "" -a ! "$NEW_VAR" = "" ]; then
        msg -w "Crontab added for user:" "${VAR_U}"
        msg $F "NEW" "$NEW_VAR" | tr '%' '*'; RC=1;
      elif [ ! "$NEW_VAR" = "$OLD_VAR" ]; then
        msg -w "Crontab changed for user:" "${VAR_U}"
        $VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
        [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR" | tr '%' '*'; RC=1; }
        $VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
        [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR" | tr '%' '*'; RC=1; }
      fi
    done
    ;;
    "df-m"|"df-vm")
    for FS in $(cat $NEW $OLD | grep "[0-9]%" | cut -f2- -d\  | awk '{print $5}'); do
      NEW_VAR=$(grep " ${FS}$" $NEW | cut -f2- -d\  | awk '{print $1}')
      OLD_VAR=$(grep " ${FS}$" $OLD | cut -f2- -d\  | awk '{print $1}')
      [[ $NEW_OLD -eq $OLD_NEW ]] || { msg -w "Filesystem '$FS' size is different:" "Old: $OLD_VAR / New: $NEW_VAR"; RC=1; }
    done
    ;;
     "timezone")
    diff $NEW $OLD >/dev/null 2>&1
    if [ ! $? -eq 0 ]; then
      VAR=$(diff $NEW $OLD | grep "^>" | cut -c3-)
      [ ! "$VAR" = "" ] && msg "$F" "OLD" "$VAR"
      VAR=$(diff $OLD $NEW | grep "^>" | cut -c3-)
      [ ! "$VAR" = "" ] && msg "$F" "NEW" "$VAR"
      RC=1
    fi
    ;;
     "ETC_runlevel")
     diff $NEW $OLD >/dev/null 2>&1
    if [ ! $? -eq 0 ]; then
      VAR=$(diff $NEW $OLD | grep "^>" | cut -c3-)
      [ ! "$VAR" = "" ] && msg "$F" "OLD" "$VAR"
      VAR=$(diff $OLD $NEW | grep "^>" | cut -c3-)
      [ ! "$VAR" = "" ] && msg "$F" "NEW" "$VAR"
      RC=1
    fi
    ;;
     "ETC_resolv_conf")
     diff $NEW $OLD >/dev/null 2>&1
    if [ ! $? -eq 0 ]; then
      VAR=$(diff $NEW $OLD | grep "^>" | cut -c3-)
      [ ! "$VAR" = "" ] && msg "$F" "OLD" "$VAR"
      VAR=$(diff $OLD $NEW | grep "^>" | cut -c3-)
      [ ! "$VAR" = "" ] && msg "$F" "NEW" "$VAR"
      RC=1
    fi
    ;;
    "BOOT_grub")
    NEW_VAR=$(grep "^default=" $NEW | cut -f2 -d=)
    NEW_VAR=$(grep -w "^title" $NEW | cut -f2- -d\  | head -$(($NEW_VAR+1)) | tail -1)
    OLD_VAR=$(grep "^default=" $OLD | cut -f2 -d=)
    OLD_VAR=$(grep -w "^title" $OLD | cut -f2- -d\  | head -$(($OLD_VAR+1)) | tail -1)
    [ "$NEW_VAR" = "$OLD_VAR" ] || { msg -w "Grub default boot value has changed:" "Old: $OLD_VAR / NEW: $NEW_VAR"; RC=1; }
    VAR=$(grep -w "^title" $NEW $OLD | cut -f2- -d\  | sort -u)
    VAR_C=$(echo "$VAR" | wc -l)
    while [[ $VAR_C -gt 0 ]]; do
      VAR_T=$(echo "$VAR" | head -${VAR_C} | tail -1)
      NEW_VAR=$(cat $NEW | sed "s/^title/\ntitle/g" | pGrep "^title ${VAR_T}$" | grep -v "^#")
      OLD_VAR=$(cat $OLD | sed "s/^title/\ntitle/g" | pGrep "^title ${VAR_T}$" | grep -v "^#")
      if [ "$NEW_VAR" = "" ]; then
        msg -w "Grub entry removed:" "${VAR_T}"
        RC=1
      elif [ "$OLD_VAR" = "" ]; then
        msg -w "Grub entry added:" "${VAR_T}"
        RC=1
      elif [ ! "$NEW_VAR" = "$OLD_VAR" ]; then
        msg -w "Grub entry changed:" "${VAR_T}"
        VAR_T=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
        msg $F "OLD" "$VAR_T"
        VAR_T=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
        msg $F "NEW" "$VAR_T"
        RC=1
      fi
      VAR_C=$((${VAR_C}-1))
    done

    NEW_VAR=$(pGrep "^title" $NEW "-v" | grep -v -E "^default=|^#|^ *$")
    OLD_VAR=$(pGrep "^title" $OLD "-v" | grep -v -E "^default=|^#|^ *$")
    if [ ! "$NEW_VAR" = "$OLD_VAR" ]; then
      msg -w "Grub values have changed:"
      $VAR=$(echo "$OLD_VAR" | grep -F -w -v "$NEW_VAR")
      [ ! "$VAR" = "" ] && { msg $F "OLD" "$VAR" | tr '%' '*'; RC=1; }
      $VAR=$(echo "$NEW_VAR" | grep -F -w -v "$OLD_VAR")
      [ ! "$VAR" = "" ] && { msg $F "NEW" "$VAR" | tr '%' '*'; RC=1; }
    fi
    ;;
    *)
    return 2 ;; # diff $NEW $OLD >/dev/null 2>&1 || RC=1;;
     esac
    return $RC
}

compare_info()
{
     [ "$1" = "-q" ] && shift && QUIET=1 || QUIET=0

     DIR=configuration_$(uname -n)
     V1="$1"
     V2="$2"

     display_history $V1 $V2
     [ "$V1" = "" ] && read -p "Enter 1st reference point in time - NEW [0]: " V1
     [ "$V1" = "" ] && V1=0 || V1=$(printf "%d" $V1 2>/dev/null)
     [ "$V2" = "" ] && read -p "Enter 2nd reference point in time - OLD [1]: " V2
     [ "$V2" = "" ] && V2=1 || V2=$(printf "%d" $V2 2>/dev/null)
     if [ "${HISTORY[$V1]}" = "" -o "${HISTORY[$V2]}" = "" -o $V1 -eq $V2 ]; then
          msg -e "Entered values are not good."
          return 1
     fi

     msg "Processing" "Comparing ${HISTDATE[$V2]} (OLD) with ${HISTDATE[$V1]} (NEW)."
     DIR[$V1]=$(gunzip -c < ${HISTORY[$V1]} | tar -tvf - | head -1 | cut -f3 -d/)
     DIR[$V2]=$(gunzip -c < ${HISTORY[$V2]} | tar -tvf - | head -1 | cut -f3 -d/)

     F_LIST=$(gunzip -c < ${HISTORY[$V1]} | tar -tvf - | grep "^-" | cut -f4 -d/ | sort)

     for F in ${F_LIST}; do
          gunzip -c < ${HISTORY[$V1]} | tar -xvf - "./${DIR[$V1]}/$F" >/dev/null 2>&1
          if [ -f "./${DIR[$V1]}/$F" ]; then
               mv "./${DIR[$V1]}/$F" /tmp/NEW.$$
          else
               msg -w "$F was not retrieved."
               continue
          fi

          gunzip -c < ${HISTORY[$V2]} | tar -xvf - "./${DIR[$V2]}/$F" >/dev/null 2>&1
          if [ -f "./${DIR[$V2]}/$F" ]; then
               mv "./${DIR[$V2]}/$F" /tmp/OLD.$$
          else
               msg "$F" "N/A"
               rm -f /tmp/NEW.$$
               continue
          fi
#          [ $QUIET -eq 0 ] && echo -e "Processing : ${F}\r\c"
          [ $QUIET -eq 1 ] && VERBOSE=0

          get_diff $F /tmp/NEW.$$ /tmp/OLD.$$
          case $? in

0) [ $QUIET -eq 1 ] && VERBOSE=1 ;msg "$F" "OK" ;;
1) [ $QUIET -eq 1 ] && VERBOSE=1 ; msg "$F" "KO" ;;
2) [ $QUIET -eq 1 ] && VERBOSE=1 ; [ $DEBUG -eq 3 ] && msg "$F" "N/A" ;;

#               0) [ $QUIET -eq 1 ] && VERBOSE=1 || echo -e "                                        \r\c" ; msg "$F" "OK" ;;
#               1) [ $QUIET -eq 1 ] && VERBOSE=1 || echo -e "                                        \r\c" ; msg "$F" "KO" ;;
#               2) [ $QUIET -eq 1 ] && VERBOSE=1 || echo -e "                                        \r\c" ; [ $DEBUG -eq 3 ] && msg "$F" "N/A" ;;
               *) echo -e "                                        \r\c" ;; 
          esac

          rm -f /tmp/NEW.$$ /tmp/OLD.$$
     done
     [ -d ./${DIR[$V1]} ] && rmdir ./${DIR[$V1]}
     [ -d ./${DIR[$V2]} ] && rmdir ./${DIR[$V2]}

     [ "$3" = "LIVE" ] && rm -f ${HISTORY[$V1]}
}

generate_config()
{
     [ "$CONFFILE" = "" ] && { msg -e "Configuration file is not defined."; exit 1; }
     [ -s "$CONFFILE" ] && { msg -w "Configuration file exists." "'$CONFFILE'"; exit 1; }
     touch $CONFFILE || { msg -e "Cannot create configuration file." "'$CONFFILE'"; exit 1; }

cat > "$CONFFILE" <<EOF

SNAPHIST="$SNAPHIST"
RUN_DIR="$RUN_DIR"
LOG_FILE="$LOG_FILE"
LOCATION="$LOCATION"
CHANGELN="$CHANGELN"
LOCOWNER="$LOCOWNER"
LOCPERMI="$LOCPERMI"
CRONFILE="$CRONFILE"
CRONTEXT="$CRONTEXT"
CRONLINE="$CRONLINE"
EOF

     [ -s "${CONFFILE}" ] && { msg -s "Config generated successfuly." "'$CONFFILE'"; }
}

proactive_actions()
{
     for VAR in $(ls /etc/sysconfig/network-scripts/ifcfg-eth* 2>/dev/null); do
          V1=$(grep "^HWADDR=" $VAR | cut -f2 -d= | tr "[A-Z]" "[a-z]")
          if [ "$V1" = "" ]; then
               msg -w "NET" "There is no MAC address in the configuration file for: ${VAR##*-}";
          else
               V2=$(ifconfig ${VAR##*-} | head -1 | awk '{print $5}' | tr "[A-Z]" "[a-z]")
               [[ "$V1" = "$V2" ]] || { msg -w "NET" "Stored MAC Address is different then the one in use on: ${VAR##*-}"; }
          fi
     done

     VAR=$(netstat -rn | grep -w "^0.0.0.0" | awk '{print $2}')
     if [[ "$VAR" = "" ]]; then
          msg -w "Routing" "Default gateway not defined."
     elif [[ $(echo "$VAR" | wc -l) -gt 1 ]]; then
          msg -w "Routing" "More than 1 default gateway found:" "$VAR"
     fi
          VAR=$(df -vm | cut -f2- -d\  | grep -w "100%" | awk '{print $5}' | tr "\n" " ")
          [[ "$VAR" = "" ]] || { msg -e "FS" "Full: $VAR"; }
          VAR=$(df -vm | cut -f2- -d\  | grep -w "9[7-9]%" | awk '{print $5}' | tr "\n" " ")
          [[ "$VAR" = "" ]] || { msg -w "FS" "Almost Full: $VAR"; }
          VAR=$(df -vm | cut -f2- -d\  | grep -w "9[4-6]%" | awk '{print $5}' | tr "\n" " ")
          [[ "$VAR" = "" ]] || { msg -i "FS" "To Pay attention: $VAR"; }
          MNT=$(mount | grep -w -E "ext[234]|nfs|xfs" | awk '{print $3}')
          FST=$(grep -v "^#" /etc/fstab | awk '{print $2}' | grep "^/")
          for VAR in $MNT; do
               echo "$FST" | grep -q "^$VAR$" || \
               { msg -w "Mounted filesystem NOT present in /etc/fstab:" "$VAR"; RC=1; }
          done
          for VAR in $FST; do
               echo "$MNT" | grep -q "^$VAR$" || \
               { msg -w "Filesystem from /etc/fstab NOT mounted now:" "$VAR"; RC=1; }
          done

     for VAR in $(mount | grep nfs | awk '{print $3}'); do
          ls -ld "$VAR" >/dev/null 2>&1
          [[ $? -eq 0 ]] || { msg -w "NFS" "Stale/Frozen file system: $VAR"; }
     done
}

print_usage()
{
     msg -i "Primary Usage" "$1 [ -h | -c | -C | -b ]"
     msg "----------" "------------------------------------------------------------"
     msg " -h" "Print help information."
     msg " -b" "Create a new snapshot (Pre-check)"
     msg " -c" "Create a new snapshot and compare it to the previous one. (Post-check)"
     msg " -C" "Display all available snapshots and chose which 2 to compare."
}

if [ -s $CONFFILE ]; then
      if [ $(grep -v "^#" $CONFFILE | grep -v "[A-Z]*=\"[0-9a-zA-Z/-_\* \$\.]*\"" | wc -l) -gt 0 ]; then
          msg -e "Problems found in config file, incorrect syntax detected:"
          grep -v "^#" $CONFFILE | grep -v "[A-Z]*=\"[0-9a-zA-Z/_\* \$\.\-]*\""
          exit 1
      fi
     . $CONFFILE
fi

[ ! "$(whoami)" = "root" ] && export RUN_DIR=${HOME}/UNIX && LOG_FILE=${HOME}/$(basename $LOG_FILE)

if [ ! -d $RUN_DIR ]; then
     mkdir -p $RUN_DIR 2>/dev/null || { msg -e "'$RUN_DIR' directory does not exist."; exit 1; }
fi

case $1 in
     "-c")    gather_info; compare_info 0 1; proactive_actions ;;
     "-C")    compare_info; proactive_actions ;;
     "-b")    gather_info ;;
     "")      print_usage $0 ;;
     "-h")   print_usage $0 ;;
     *)      print_usage $0 ;;
esac # 2>&1 | tee -a $LOG_FILE
