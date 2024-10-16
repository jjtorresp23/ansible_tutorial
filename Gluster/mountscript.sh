echo "#!/bin/bash" >> mount.sh
for i in `cat gluster.out`
do
echo "df -h $i" >> mount.sh
echo "RES=\$?" >> mount.sh
echo "if [ \$RES == 0 ]; then" >> mount.sh
echo "   date >> /var/log/mounted.log" >> mount.sh
echo "   echo \"FS $i is mounted! No actions needed!\" >> /var/log/mounted.log" >> mount.sh
echo "   echo \"--------------------------------\" >> /var/log/mounted.log" >> mount.sh
echo "  else" >> mount.sh
echo "   sudo umount -l $i" >> mount.sh
echo "   sudo mount -a" >> mount.sh
echo "   date >> /var/log/mounted.log" >> mount.sh
echo "   echo \"FS $i was re-mounted!\" >> /var/log/mounted.log" >> mount.sh
echo "   echo \"--------------------------------\" >> /var/log/mounted.log" >> mount.sh
echo "fi" >> mount.sh
echo " " >> mount.sh
done
