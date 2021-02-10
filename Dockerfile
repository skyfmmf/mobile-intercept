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
# hadolint ignore=DL3013
RUN python3 -m ensurepip && \
    pip3 install --no-cache-dir --upgrade pip setuptools wheel
RUN pip3 install --no-cache-dir mitmproxy==6.0.2

COPY setup.sh /usr/local/bin/mi-setup
COPY intercept.sh /usr/local/bin/mi-intercept
COPY view.sh /usr/local/bin/mi-view
