echo "########################## HOSTNAME ###########################" >> `hostname -s`_data.out
uname -a >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################## SERVER DATE ###########################" >> `hostname -s`_data.out
date >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### uptime ###########################" >> `hostname -s`_data.out
uptime  >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### os ver ###########################" >> `hostname -s`_data.out
cat /etc/redhat-release >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### DF -H ###########################" >> `hostname -s`_data.out
df -h >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### MOUNT ###########################" >> `hostname -s`_data.out
mount >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### LSBLK ###########################" >> `hostname -s`_data.out
lsblk >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### ifconfig ###########################" >> `hostname -s`_data.out
ifconfig -a >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
ip a >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### netstat -nr ###########################" >> `hostname -s`_data.out
netstat -nr >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### netstat -na ###########################" >> `hostname -s`_data.out
netstat -na >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### PS -FEA ###########################" >> `hostname -s`_data.out
ps -fea >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### FDISK -L ###########################" >> `hostname -s`_data.out
fdisk -l >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### PVS ###########################" >> `hostname -s`_data.out
pvs >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### VGS ###########################" >> `hostname -s`_data.out
vgs >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### LVS ###########################" >> `hostname -s`_data.out
lvs >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### MULTIPATH  ###########################" >> `hostname -s`_data.out
multipath -ll >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### oracle ASM list disks ###########################" >> `hostname -s`_data.out
oracleasm listdisks >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "########################### DMIDECODE ###########################" >> `hostname -s`_data.out
dmidecode --type=1 >> `hostname -s`_data.out
echo "   " >> `hostname -s`_data.out
echo "--------------------    EOF    --------------------" >> `hostname -s`_data.out
exit
