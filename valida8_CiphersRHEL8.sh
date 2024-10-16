for i in `cat inventory`
do
echo $i 
ssh $i ls -l /etc/crypto-policies/policies/modules/DISABLE-CBC.pmod
ssh $i sudo update-crypto-policies --show
echo "--------------------------------------------------------------"
done
