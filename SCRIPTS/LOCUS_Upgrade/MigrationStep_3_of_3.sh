#!/bin/bash
echo "Upgrading Charon UTN Manager....."
rpm -ivh /home/lii01.livun.com/juan.torresp/sehutnmanager-rpm_linux_64bit-4.0.7/seh-utn-driver-4.0.7-1dkms.noarch.rpm
rpm -ivh /home/lii01.livun.com/juan.torresp/sehutnmanager-rpm_linux_64bit-4.0.7/seh-utn-service-4.0.7-1.x86_64.rpm
rpm -ivh /home/lii01.livun.com/juan.torresp/sehutnmanager-rpm_linux_64bit-4.0.7/seh-utn-clitool-4.0.7-1.x86_64.rpm
rpm -ivh /home/lii01.livun.com/juan.torresp/xcb-util-cursor-0.1.3-9.el8.x86_64.rpm
rpm -ivh /home/lii01.livun.com/juan.torresp/sehutnmanager-rpm_linux_64bit-4.0.7/seh-utn-manager-4.0.7-1.x86_64.rpm
echo "Installed."
echo "Upgrading Charon Emulator....."
Path: /opt/charon/charon_dist/charon-axp-4.11-20415.el8
rpm -ivh /home/lii01.livun.com/juan.torresp/charon-axp-4.11-20415.el8/aksusbd-8.13-1.x86_64.rpm
rpm -ivh /home/lii01.livun.com/juan.torresp/charon-axp-4.11-20415.el8/charon-license-4.11-20415.el8.x86_64.rpm
rpm -ivh /home/lii01.livun.com/juan.torresp/charon-axp-4.11-20415.el8/charon-axp-4.11-20415.el8.x86_64.rpm
rpm -ivh /home/lii01.livun.com/juan.torresp/charon-axp-4.11-20415.el8/charon-mtd-4.11-20415.el8.x86_64.rpm
rpm -ivh /home/lii01.livun.com/juan.torresp/charon-axp-4.11-20415.el8/charon-utils-4.11-20415.el8.x86_64.rpm
echo "Installed."
