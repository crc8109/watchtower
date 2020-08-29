# Watchtower

Configurations for my HTPC.

Using docker-compose to deploy the following:
* alertmanager
* cadvisor
* grafana
* jackett
* node-exporter
* plex
* portainer
* prometheus
* qbittorrentvpn
* radarr
* redis
* sonarr
* traefik

## Environment File

Set to `.env`. Referenced in the systemd unit and in each Docker Compose service that supports PUID/PGID env vars. Contains much of the following:

```
DOMAIN=example.com
PGID=1000
PUID=1000
TZ="America/New_York"
```

## Traefik

Using Traefik as the reverse proxy for serving all of the containers to the home network. Define `.htpasswd` before starting Traefik:

```
htpasswd -c /etc/watchtower/traefik/.htpasswd admin
```

Config leverages TLS certs (for my homelab). Update traefik.toml accordingly with your own certs or disable altogether.

## Known Issues

### `watchtower.service: Job watchtower.service/start failed with result 'dependency'.`
`watchtower.service` depends on `networking.service` and `docker.service` being up and running. The former may fail to load in a fresh install of Debian 10.5 if your network interface is not named eth0 (default defined). Edit `/etc/network/interfaces.d/setup` and restart `networking.service`.

## TODO

* automated TLS renewal using Let's Encrypt
* complete Grafana dashboard
* convert setup.sh to Makefile

