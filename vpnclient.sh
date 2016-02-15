#!/bin/bash
# Public IP bridging via Softether VPN for Ubuntu
echo -n "Enter Server IP: "
read SERVER_IP
echo -n "Enter VPN Server Username: "
read USER
read -s -p "Enter VPN Server Password: " SERVER_PASSWORD
echo ""
echo -n "Enter primary proxied IP to use (e.g. 8.8.8.8): "
read CLIENT_IP
echo -n "Enter network mask bits, don't use /, (e.g. for /24 enter 24): "
read CLIENT_NETBLOCK
echo -n "Enter network (e.g. 8.8.8.0): "
read CLIENT_NETWORK
echo -n "Enter gateway (e.g. 8.8.8.1): "
read CLIENT_GATEWAY
echo ""
echo "+++ Now sit back and wait until the installation finished +++"
HUB="VPN"
USER_PASSWORD=${SERVER_PASSWORD}
TARGET="/usr/local/"
IP_TABLE="vpntable"

apt-get update && apt-get -qq upgrade
apt-get -y install wget build-essential expect
sleep 2
wget http://www.softether-download.com/files/softether/v4.19-9599-beta-2015.10.19-tree/Linux/SoftEther_VPN_Client/64bit_-_Intel_x64_or_AMD64/softether-vpnclient-v4.19-9599-beta-2015.10.19-linux-x64-64bit.tar.gz
tar xzvf softether-vpnclient-v4.19-9599-beta-2015.10.19-linux-x64-64bit.tar.gz -C $TARGET
rm -rf softether-vpnclient-v4.19-9599-beta-2015.10.19-linux-x64-64bit.tar.gz
cd ${TARGET}vpnclient
expect -c 'spawn make; expect number:; send 1\r; expect number:; send 1\r; expect number:; send 1\r; interact'
find ${TARGET}vpnclient -type f -print0 | xargs -0 chmod 600
chmod 700 ${TARGET}vpnclient/vpnclient ${TARGET}vpnclient/vpncmd
mkdir -p /var/lock/subsys
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/ipv4_forwarding.conf
echo "1 ${IP_TABLE}" >> /etc/iproute2/rt_tables
sysctl --system
${TARGET}vpnclient/vpnclient start
sleep 2
${TARGET}vpnclient/vpncmd localhost /CLIENT /CMD AccountCreate vpn /SERVER:${SERVER_IP}:443 /HUB:${HUB} /USERNAME:${USER} /NICNAME:vpn
${TARGET}vpnclient/vpncmd localhost /CLIENT /CMD AccountPasswordSet vpn /PASSWORD:${USER_PASSWORD} /TYPE:standard
${TARGET}vpnclient/vpncmd localhost /CLIENT /CMD AccountStartupSet vpn
${TARGET}vpnclient/vpncmd localhost /CLIENT /CMD AccountConnect vpn
${TARGET}vpnclient/vpnclient stop
wget -O /etc/init.d/vpnclient https://raw.githubusercontent.com/abegodong/ipbridge/master/vpnclient
sed -i "s/\[SERVER_IP\]/${SERVER_IP}/g" /etc/init.d/vpnclient
sed -i "s/\[CLIENT_IP\]/${CLIENT_IP}/g" /etc/init.d/vpnclient
sed -i "s/\[CLIENT_NETBLOCK\]/${CLIENT_NETBLOCK}/g" /etc/init.d/vpnclient
sed -i "s/\[CLIENT_GATEWAY\]/${CLIENT_GATEWAY}/g" /etc/init.d/vpnclient
sed -i "s/\[CLIENT_NETWORK\]/${CLIENT_NETWORK}/g" /etc/init.d/vpnclient
sed -i "s/\[IP_TABLE\]/${IP_TABLE}/g" /etc/init.d/vpnclient
chmod 755 /etc/init.d/vpnclient && /etc/init.d/vpnclient start
update-rc.d vpnclient defaults
service vpnclient restart
