FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y iproute2 iptables tcpdump wireguard-tools qrencode

ADD https://snapshots.mitmproxy.org/6.0.2/mitmproxy-6.0.2-linux.tar.gz /mitmproxy.tar.gz
RUN tar -xzvf /mitmproxy.tar.gz -C /usr/local/bin

COPY init.sh /
COPY run.sh /
COPY view.sh /
