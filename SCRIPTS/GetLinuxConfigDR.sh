datee=$(date +%F_%H%M%S)
echo "########################## HOSTNAME ###########################" >> snapshot_`hostname -s`_$datee.out
uname -a >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "########################### os ver ###########################" >> snapshot_`hostname -s`_$datee.out
cat /etc/redhat-release >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "########################### DF -H ###########################" >> snapshot_`hostname -s`_$datee.out
df -h >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "########################### MOUNT ###########################" >> snapshot_`hostname -s`_$datee.out
mount >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "########################### LSBLK ###########################" >> snapshot_`hostname -s`_$datee.out
lsblk >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "########################### BLKID ###########################" >> snapshot_`hostname -s`_$datee.out
blkid >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "########################### ifconfig ###########################" >> snapshot_`hostname -s`_$datee.out
ifconfig -a >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
ip a >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "########################### netstat -nr ###########################" >> snapshot_`hostname -s`_$datee.out
netstat -nr >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "########################### FDISK -L ###########################" >> snapshot_`hostname -s`_$datee.out
fdisk -l >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "########################### PVS ###########################" >> snapshot_`hostname -s`_$datee.out
pvs >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "########################### VGS ###########################" >> snapshot_`hostname -s`_$datee.out
vgs >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "########################### LVS ###########################" >> snapshot_`hostname -s`_$datee.out
lvs >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "########################### oracle ASM list disks ###########################" >> snapshot_`hostname -s`_$datee.out
oracleasm listdisks >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "########################### DMIDECODE ###########################" >> snapshot_`hostname -s`_$datee.out
dmidecode --type=1 >> snapshot_`hostname -s`_$datee.out
echo "   " >> snapshot_`hostname -s`_$datee.out
echo "--------------------    EOF    --------------------" >> snapshot_`hostname -s`_$datee.out
exit
