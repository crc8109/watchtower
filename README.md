# Watchtower

Configurations for my HTPC.

## Environment File

Set to `.env`. Referenced in the systemd unit and in each Docker Compose service that supports PUID/PGID env vars. Contains much of the following:

```
DOMAIN=example.com
PGID=1000
PUID=1000
TZ="America/New_York"
```

## Known Issues

### `watchtower.service: Job watchtower.service/start failed with result 'dependency'.`
`watchtower.service` depends on `networking.service` and `docker.service` being up and running. The former may fail to load in a fresh install of Debian 10.5 if your network interface is not named eth0 (default defined). Edit `/etc/network/interfaces.d/setup` and restart `networking.service`.

## TODO

~~* Automate TLS renewal using Let's Encrypt~~
* Complete Grafana dashboard
* Convert setup.sh to Makefile
* Add Ombi for notifications
* Add Lidarr for music procurement
* Add Tautulli for monitoring Plex

