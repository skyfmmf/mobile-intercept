FROM alpine:3.13

RUN apk add --update --no-cache \
    iproute2 \
    iptables \
    wireguard-tools \
    libqrencode \
    python3 \
    gcc \
    g++ \
    libffi-dev \
    python3-dev \
    musl-dev \
    openssl-dev \
    tcpdump
RUN python3 -m ensurepip && \
    pip3 install --upgrade pip setuptools wheel
RUN pip3 install mitmproxy

COPY setup.sh /usr/local/bin/mi-setup
COPY intercept.sh /usr/local/bin/mi-intercept
COPY view.sh /usr/local/bin/mi-view
