# Watchtower

Configurations for my HTPC.

Using docker-compose to deploy the following:
* jackett
* plex
* portainer
* qbittorrent
* radarr
* sonarr
* traefik
* whoami

## systemd
See config/systemd/docker-compose.service for an example that updates/deploys containers at system startup.

### Environment File
| Key         | Value                      |
|-------------|----------------------------|
| PUID        | 1000                       |
| PGID        | 1000                       |
| TZ          | America/New_York           |
| PLEX_CLAIM  | claim-XXXXXXXXXXXXXXXXXXXX |
| CONFIG_PATH | /config                    |
| MEDIA_PATH  | /media                     |
| PLEX_PATH   | /var/lib/plex              |

If not using a systemd unit, be sure to define in your env or modify compose manifest.

### Traefik
Certs are obviously not included here. Let's Encrypt is highly recommended for a quick and easy HTTPS bundle.
