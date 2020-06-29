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

Set to ```.env```. Referenced in the systemd unit and in each Docker Compose service that supports PUID/PGID env vars. Contains much of the following:

```
DOMAIN=example.com
PGID=1000
PUID=1000
TZ="America/New_York"
```

