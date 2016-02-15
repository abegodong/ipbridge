# ipbridge

Tools to assign public IP in a network to another network through vpn tunneling.

## What is this?

This is a tool to assign a public IP available in a network to other networks through VPN connection.

When you have a server (let's call it SERVER A) with a lot of public IPs in a network (NETWORK A), and you have other servers (SERVER B) in other networks (NETWORK B) that have a limited IP, or is behind a firewall,
and you want to assign one or more available public IPs in network A to the server in network B through VPN, this tool will help you to achieve that. The traffic transferred between network A and network B will be securely transmitted (encrypted).

Keep in mind that the traffic between the server and the client counts toward your internet bandwidth buckets, so if your provider limits it be aware, that you'll incure twice as much as you normally would. Here's an illustration:

Client -----> Server A -----> Server B ------> Server A -----> Client

## How it works?

It works by setting a Softether VPN server in SERVER A, and then setting up a Softether VPN Client in SERVER B, and manually allocate unassigned available IP in NETWORK A to the SERVER B. Of course this is not limited to one-on-one setup, you can actually have a lot of VPN clients on different network to access network A IP pool.

For this to work, you'd need:

* Available, unassigned IPs in a network (can be in the same subnet as the server IP, or not)
* A ubuntu 14.04 or debian 8 in both the server and clients (These are the only OS I tested it with, you might need to tweak it to work with other OS).
* Dedicated Server is preferable as VPS might not work if the IP is automatically assigned to an interface.
* Some knowledge how to troubleshoot if something goes wrong!
* Port 443 available in Server A for VPN communication, if you need it for other purpose or want to use different port, you'd need to tweak the script.

WARNING: You might lose remote access connection, data, intellectual property, etc ... if something goes wrong! Handle with care!

## How to use it?

Step 1: Gather all the information you'd need: IP Address (e.g. 10.0.0.10), network mask bits (e.g. /24), gateway ip (e.g. 10.0.0.1), and network (e.g. 10.0.0.0). 
Step 2: Run vpnserver.sh in SERVER A that you have a lot of IP to share, this will install Softether VPN server and configure it.
```
wget https://raw.githubusercontent.com/abegodong/ipbridge/master/vpnserver.sh && bash vpnserver.sh
```
Step 3: Ensure that you unassign IP that you want to use in other servers from the SERVER A virtual network interfaces.
Step 4: Run vpnclient.sh in SERVER B that you want to assign the IP to, this will install Softether VPN client and configure it.
```
wget https://raw.githubusercontent.com/abegodong/ipbridge/master/vpnclient.sh && bash vpnclient.sh
```
Step 5: Try to ping other IP in Network A from server B, then wait few minutes and test the new IP (browsing, etc ...).
Step 6: If you need to add more IPs in server B, simply run: `ip addr add ${CLIENT_IP}/${CLIENT_NETBLOCK} dev vpn_vpn` , for example: `ip addr add 10.0.0.10/24 dev vpn_vpn`

That's it, you can run vpnclient.sh in other servers as needed.

## License?

MIT (see license.txt).

## Credits ...

Some parts of this tool are built based on:
* https://www.digitalocean.com/community/articles/how-to-setup-a-multi-protocol-vpn-server-using-softether

And thank you for the awesome folks at University if Tsukuba, Japan who've built the Softether VPN (https://www.softether.org/)
