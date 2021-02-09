#!/bin/sh

IFNAME="${IFNAME:-wgspy0}"
SHARE="/share"

PEER_NUM="${PEER_NUM:-1}"
WG_SUBNET="${WG_SUBNET:-10.255.255}"
WG_SRV_IP="${WG_SUBNET}.254"

umask 077
if [ ! -e "${SHARE}/server.key" ]; then
    wg genkey > "${SHARE}/server.key"
fi
if [ ! -e "${SHARE}/server.pub" ]; then
    wg pubkey < "${SHARE}/server.key" > "${SHARE}/server.pub"
fi
if [  ! -e "${SHARE}/server.conf" ]; then
    cat << EOF > "${SHARE}/server.conf"
[Interface]
PrivateKey = $(cat "${SHARE}/server.key")
ListenPort = ${EXT_PORT}
EOF
fi

for pid in $(seq $PEER_NUM); do
    peer_ip="${WG_SUBNET}.${pid}"
    if [ ! -e "${SHARE}/peer${pid}.key" ]; then
        wg genkey > "${SHARE}/peer${pid}.key"
    fi
    if [ ! -e "${SHARE}/peer${pid}.pub" ]; then
        wg pubkey < "${SHARE}/peer${pid}.key" > "${SHARE}/peer${pid}.pub"
    fi

    if [  ! -e "${SHARE}/peer${pid}.conf" ]; then
        cat << EOF > "${SHARE}/peer${pid}.conf"
[Interface]
Address = ${peer_ip}/24
PrivateKey = $(cat "${SHARE}/peer${pid}.key")
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = $(cat "${SHARE}/server.pub")
Endpoint = ${EXT_IP}:${EXT_PORT}
AllowedIPs = 0.0.0.0/0
EOF
        cat << EOF >> "${SHARE}/server.conf"
[Peer]
PublicKey = $(cat "${SHARE}/peer${pid}.pub")
AllowedIPs = ${peer_ip}/32
EOF
    fi
done

ip link add dev "${IFNAME}" type wireguard
ip address add dev "${IFNAME}" "${WG_SRV_IP}/24"
wg setconf "${IFNAME}" "${SHARE}/server.conf"
ip link set up dev "${IFNAME}"

iptables -t nat -A PREROUTING -i "${IFNAME}" -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -i "${IFNAME}" -p tcp --dport 443 -j REDIRECT --to-port 8080
iptables -t nat -A POSTROUTING -s "${WG_SUBNET}.0/24" -o eth0 -j MASQUERADE

echo "WireGuard configured."
for pid in $(seq $PEER_NUM); do
    echo "Scan the QR code to configure peer ${pid}."
    qrencode -t ansiutf8 < "${SHARE}/peer${pid}.conf"
done
