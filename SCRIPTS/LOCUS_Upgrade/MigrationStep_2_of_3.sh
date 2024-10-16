#!/bin/bash
echo "Preparing System for Migration..."
echo "---------------------------------------------------------------------------"
subscription-manager repos --enable rhel-7-server-extras-rpms
yum -y install leapp leapp-repository
rmmod floppy pata_acpi 
## /or/  
modprobe -r floppy pata_acpi
ln -snf var/lib/snapd/snap /snap
leapp answer --section remove_pam_pkcs11_module_check.confirm=True
leapp answer --section authselect_check.confirm=True
leapp answer --section remove_pam_pkcs11_module_check.confirm=True
yum -y remove kernel-devel-3.10.0-1160.114.2.el7 kernel-devel-3.10.0-1160.118.1.el7
echo "System is ready for Migration..."
