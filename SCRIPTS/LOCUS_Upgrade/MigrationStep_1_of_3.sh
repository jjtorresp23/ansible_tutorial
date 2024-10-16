#!/bin/bash
echo "----------------------------------------------------------------------------------------"
echo "Step 1 of 5, Subscribing to RHEL.."
subscription-manager remove --all
subscription-manager unregister
subscription-manager clean
subscription-manager register --username "lii.luis.ramirez" --password "NuevoProyecto.11"
subscription-manager attach --pool=2c94868c8379b71b01838536544d43f8
echo "Subscribed."
echo "----------------------------------------------------------------------------------------"
echo "Step 2 of 5, Removing Base Software.."
rpm -qa|grep mdatp|xargs -i rpm -e {}
rpm -qa|grep check-mk-agent|xargs -i rpm -e {}
rpm -qa|grep TaniumClient|xargs -i rpm -e {}
rpm -qa|tet-sensor|xargs -i rpm -e {}
rpm -qa|falcon-sensor|xargs -i rpm -e {}
rpm -qa|grep -i splunkforwarder|xargs -i rpm -e {}
echo "Removed."
echo "----------------------------------------------------------------------------------------"
echo "Step 3 of 5, Removing UTN Software.."
rpm -qa|grep seh-utn-manager|xargs -i rpm -e {}
rpm -qa|grep seh-utn-clitool|xargs -i rpm -e {}
rpm -qa|grep seh-utn-service|xargs -i rpm -e {}
rpm -qa|grep seh-utn-driver|xargs -i rpm -e {}
echo "Removed."
echo "----------------------------------------------------------------------------------------"
echo "Step 4 of 5, Removing Charon Emulator Software.."
rpm -qa|grep charon-axp|xargs -i rpm -e {}
rpm -qa|grep charon-utils|xargs -i rpm -e {}
rpm -qa|grep charon-license|xargs -i rpm -e {}
rpm -qa|grep charon-mtd|xargs -i rpm -e {}
rpm -qa|grep aksusbd|xargs -i rpm -e {}
echo "Removed."
echo "----------------------------------------------------------------------------------------"
echo "Step 5 of 5, Updating All Packages.."
yum -y update
echo "Updated."
echo "---------------------------------------Script Completed---------------------------------"
