# Intercepting traffic from a mobile phone

This project aims to simplify the setup of an intercepting proxy for HTTP and
HTTPS to be used with mobile devices. The main idea is to create a VPN using
[WireGuard](https://www.wireguard.com/) for the mobile device to join and run a
transparent [mitmproxy](https://mitmproxy.org/) to intercept the traffic. The
key material for the VPN and HTTPS interception is handled mostly
automatically. All this happens in Docker container that can easily be started
and stopped without having to fiddle with the network configuration of the
intercepting host.

The reason for the use of a VPN is twofold. Firstly, it allows a quick
configuration on the device. There is no need to configure proxies on the
device and the interception can be turned on/off by activating/deactivating the
VPN. Secondly, it allows to intercept traffic even in changing network
environments (e.g., in a local WiFi and on the go in the cellular network), as
long as the VPN can stay active.

## How does it work?

All software runs inside a Docker container. Inside the container, a WireGuard
interface is active that receives traffic over a port forwarding. There are
iptables rules in place to perform NAT on the traffic from the mobile device.
Traffic to the ports 80 (HTTP) and 443 (HTTPS) is redirected to a mitmproxy
instance that runs in the container. This proxy performs the HTTPS
interception. The whole setup of the environment happens in `setup.sh`. Please
consult this file if you need to make modifications to the setup.

## How to use

1. Make sure to fulfill the following prerequisites:
    - The intercepting host needs to have Docker installed and needs to be
      reachable from all networks that the mobile device should be intercepted
      in.
    - The mobile device needs to be able to connect to WireGuard VPNs,
      preferably using the WireGuard mobile app
2. Configure the IP address for start the VPN server in the `.env` file. This
   address needs to be reachable from the mobile device.
3. Start the container by running `docker-compose up -d`
4. Start a shell inside the container using `docker-compose exec mitmproxy
   bash`
5. Now run `mi-setup` inside the container. This will setup the VPN and print a
   QR code that can be scanned with the mobile device to connect to the VPN.
   The VPN configuration can also be found as plain text in the shared folder.
6. Run `mi-intercept` to start mitmproxy. This will start the interception and
   show a TUI showing the traffic. Inside mitmproxy, you can use all its
   functionalities like modifying the requests/responses as well. The traffic
   is also stored in a file in the shared folder.
7. On the mobile device: join the VPN that was configured with the QR code from
   step 5. Next, go to `mitm.it` with the web browser and add the mitmproxy CA
   to the trust store of your device. The page contains documentation for all
   common operating systems. This step is required to be able to read the HTTPS
   traffic.
8. Optional: if you want to examine an old traffic capture, you can run
   `mi-view FILENAME` inside the container.
9. After exiting the container, you can run `docker-compose down` to get rid of
   the whole environment. Your traffic captures will stay in the shared folder.

The shared folder is `share/` in this repository. It will contain the key
material for the VPN, the VPN configurations, and the CA key material for
mitmproxy. This allows to start the environment again at a later time and keep
using the configured VPN connection and trusted CA on the mobile device.
However, use you own judgement if you want to keep the mitmproxy root CA in
your trust store in a long-term (hint: iOS has an option to distrust root CAs
without removing them). All key material stays local on your devices and is
never sent anywhere.

If you want to intercept traffic from more than one mobile device, configure
the `PEER_NUM` variable in `.env`.

## Notes

This project just makes it easy to setup the required software. It can not do
stuff that mitmproxy can not do. For example, if a mobile application uses
certificate pinning, you will not be able to decrypt the traffic. However, the
connection will not be successful and you will see a note about the failed
connection at the bottom of mitmproxy (i.e., connections with certificate
pinning do not silently circumvent the proxy).

On Android, further steps may be required to make apps on the system accept the
root CA from mitmproxy. Consult [their
documentation](https://docs.mitmproxy.org/stable/howto-install-system-trusted-ca-android/)
for details.



_Disclaimer: "WireGuard" and the "WireGuard" logo are registered trademarks of
Jason A. Donenfeld._
