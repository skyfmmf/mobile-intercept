FROM golang:1.16-alpine as builder
# hadolint ignore=DL3018
RUN apk add --update --no-cache \
    git \
    make
RUN git clone https://git.zx2c4.com/wireguard-go /wireguard-go
WORKDIR /wireguard-go
# Newer versions cause a hang when using wg(8) commands
RUN git checkout 0.0.20201118 && \
    make

FROM alpine:3.13
# hadolint ignore=DL3018
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
COPY --from=builder /wireguard-go/wireguard-go /usr/local/bin
# hadolint ignore=DL3013
RUN python3 -m ensurepip && \
    pip3 install --no-cache-dir --upgrade pip setuptools wheel
RUN pip3 install --no-cache-dir mitmproxy==6.0.2

COPY setup.sh /usr/local/bin/mi-setup
COPY intercept.sh /usr/local/bin/mi-intercept
COPY view.sh /usr/local/bin/mi-view
