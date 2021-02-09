#!/bin/sh

SHARE="/share"

export LANG="en_US.UTF-8"
mitmproxy --no-server --showhost --set "confdir=${SHARE}" --set "console_mouse=false" --rfile $@
