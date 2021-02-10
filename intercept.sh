#!/bin/sh

SHARE="/share"
date=$(date +"%Y%m%d-%H%M")

export LANG="en_US.UTF-8"
mitmproxy --mode transparent --showhost --anticache --set "confdir=${SHARE}" --set "console_mouse=false" --save-stream-file "${SHARE}/stream-${date}.log" "$@"
