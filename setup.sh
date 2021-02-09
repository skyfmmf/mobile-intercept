#!/bin/sh

IFNAME="${IFNAME:-wgspy0}"
SHARE="${SHARE:-/share}"

umask 077
if [ ! -e "${SHARE}/server.key" ]; then
    wg genkey > "${SHARE}/server.key"
fi
if [ ! -e "${SHARE}/server.pub" ]; then
    wg pubkey < "${SHARE}/server.key" > "${SHARE}/server.pub"
fi

if [ ! -e "${SHARE}/peer.key" ]; then
    wg genkey > "${SHARE}/peer.key"
fi
if [ ! -e "${SHARE}/peer.pub" ]; then
    wg pubkey < "${SHARE}/peer.key" > "${SHARE}/peer.pub"
fi

if [  ! -e "${SHARE}/server.conf" ]; then
    cat << EOF > "${SHARE}/server.conf"
[Interface]
PrivateKey = $(cat "${SHARE}/server.key")
ListenPort = ${EXT_PORT}

[Peer]
PublicKey = $(cat "${SHARE}/peer.pub")
AllowedIPs = 10.255.255.2/32
EOF
fi

if [  ! -e "${SHARE}/peer.conf" ]; then
    cat << EOF > "${SHARE}/peer.conf"
[Interface]
Address = 10.255.255.2/24
PrivateKey = $(cat "${SHARE}/peer.key")
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = $(cat "${SHARE}/server.pub")
Endpoint = ${EXT_IP}:${EXT_PORT}
AllowedIPs = 0.0.0.0/0
EOF
fi

ip link add dev $IFNAME type wireguard
ip address add dev $IFNAME 10.255.255.1/24
wg setconf $IFNAME "${SHARE}/server.conf"
ip link set up dev $IFNAME

iptables -t nat -A PREROUTING -i ${IFNAME} -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -i ${IFNAME} -p tcp --dport 443 -j REDIRECT --to-port 8080
iptables -t nat -A POSTROUTING -s 10.255.255.0/24 -o eth0 -j MASQUERADE

echo "WireGuard configured. Scan the QR code to configure the client."
qrencode -t ansiutf8 < "${SHARE}/peer.conf"
