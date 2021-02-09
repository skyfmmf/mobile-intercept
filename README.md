# Intercepting traffic from a smartphone

## How to use

```sh
# Start the container
docker-compose up -d --build
# Connect to the container to use it
docker-compose exec mitmproxy bash
# Tear everything down afterwards
docker-compose down
```

Inside the container:
```sh
# First (generating keys, setting up WireGuard, iptables, client configuration)
/init.sh
# Use mitmproxy
/run.sh
# View a recorded stream
/view.sh <filename>
```
