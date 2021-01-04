# Watchtower

Configurations for my HTPC.

## Environment File

Set to `.env`. Referenced in the systemd unit and in each Docker Compose service that supports PUID/PGID env vars. Contains much of the following:

```
# general
PUID=1000
PGID=1000
TZ="America/New_York"

# for traefik
DOMAIN=example.com

# for plex
PLEX_CLAIM=claim-1234
HOST_IP=192.168.0.2
LAN_NETWORK=192.168.0.0/24

# for qbittorrent
NAME_SERVERS=1.1.1.1,1.0.0.1
```

## Config Location
Plex creates an incredible number of files (tens of thousands of <10MB files>) which will hamper performance on spinners as it executes housekeeping activities. To avoid saturating the notoriously little bandwidth spinners provide, config directories are stored on the local, SSD-backed, filesystem.

TODO: Automate backup of config directories (compressed into a singular archive for easy transference) to replicated storage.

## `network_mode: host`
Use when 127.0.0.1 is needed, like when referencing `speedtest` service endpoint for `telegraf`.

## qBittorrent
You must supply an .ovpn and credential file in the openvpn directory (e.g. config/qbittorrent/openvpn/server.ovpn). Otherwise disable VPN by setting `VPN_ENABLED=no`

## Known Issues

### Traefik: `Bad Gateway`
Validate in Traefik dashboard that the HTTP routers/services are active and accurate. With auto-discovery, Traefik will create an HTTP service pointing to the first-defined\* port of the container which may not be the right port for web traffic (e.g. port 8000 vs 9000 on portainer).

\* Not guaranteed. Witnessed qbittorrentvpn HTTP service being set to container\_ip:8080 despite port 8080 not being defined (expected 8181 as defined first).

### Why is Plex in `host` network mode?
~~My smart TV is unable to connect to Plex when in `bridge` mode. All other devices (PCs, tablets, smartphones) work fine in either mode. With `network_mode: host`, Plex will be attached to the home network through the Linux host (sharing its IP and reachable on exposed ports). As such, Traefik can no longer dictate routes to the underlying container and so the host IP:port must be used to reach Plex via browser. Also lose out on the HTTPS certs from Traefik + Let's Encrypt. A bit of an inconvenience but Plex server discovery works well enough.~~

Fixed (11/19): Switching to bridge network mode seems to conflict with the previous (host network mode) state/config. Had to generate a new Plex token, use the token within the 4min lifespan of the token, and create as a new server. Additionally, double-quoting environment variable values (namely PLEX\_CLAIM) causes parsing issues when the initialization process registers a new token.

### Plex: LAN Network (local vs remote streaming)
Plex identifies local devices by comparing subnets. Since Docker provides a largely isolated network (e.g. 172.17.0.0/16), separate from the home network (e.g. 192.168.0.0/24), all clients are considered remote. With remote streams configured to a limit of 8 Mb/s, virtually all content will require transcoding. Transcoding 4K to 4K is a no-no. Direct Play is ideal.

Unfortunately, LAN\_NETWORK env var does not seem to equate to the `LAN Networks` field in the Plex UI (Settings -> Network). Set it (e.g. 192.168.0.0/24) in the latter and verify in Plex Dashboard or Tautulli that the local device is recognized as a local stream.
