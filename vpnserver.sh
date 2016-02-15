#!/bin/bash
# Softether VPN Server with local bridge

SERVER_PASSWORD=""
SHARED_KEY=""
USER=""

echo -n "Enter ethernet device to use (e.g. eth0): "
read DEVICE
echo -n "Set VPN Username to create: "
read USER
read -s -p "Set VPN Password: " SERVER_PASSWORD
echo ""
echo "+++ Now sit back and wait until the installation finished +++"
HUB="VPN"
HUB_PASSWORD=${SERVER_PASSWORD}
USER_PASSWORD=${SERVER_PASSWORD}
TARGET="/usr/local/"

apt-get update && apt-get -qq upgrade
apt-get -y install wget build-essential expect bridge-utils
sleep 2
wget http://www.softether-download.com/files/softether/v4.19-9599-beta-2015.10.19-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.19-9599-beta-2015.10.19-linux-x64-64bit.tar.gz
tar xzvf softether-vpnserver-v4.19-9599-beta-2015.10.19-linux-x64-64bit.tar.gz -C $TARGET
rm -rf softether-vpnserver-v4.19-9599-beta-2015.10.19-linux-x64-64bit.tar.gz
cd ${TARGET}vpnserver
expect -c 'spawn make; expect number:; send 1\r; expect number:; send 1\r; expect number:; send 1\r; interact'
find ${TARGET}vpnserver -type f -print0 | xargs -0 chmod 600
chmod 700 ${TARGET}vpnserver/vpnserver ${TARGET}vpnserver/vpncmd
mkdir -p /var/lock/subsys
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/ipv4_forwarding.conf
sysctl --system
wget -O /etc/init.d/vpnserver https://raw.githubusercontent.com/abegodong/ipbridge/master/vpnserver
chmod 755 /etc/init.d/vpnserver && /etc/init.d/vpnserver start
update-rc.d vpnserver defaults
sleep 2
${TARGET}vpnserver/vpncmd localhost /SERVER /CMD ServerPasswordSet ${SERVER_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD HubCreate ${HUB} /PASSWORD:${HUB_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /HUB:${HUB} /CMD UserCreate ${USER} /GROUP:none /REALNAME:none /NOTE:none
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /HUB:${HUB} /CMD UserPasswordSet ${USER} /PASSWORD:${USER_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD BridgeCreate ${HUB} /DEVICE:${DEVICE} /TAP:no
service vpnserver restart
echo "+++ Installation finished +++"