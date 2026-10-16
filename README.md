# caddy-ovh

Docker image of [Caddy](https://caddyserver.com) with these plugins built in:

- [caddy-dns/ovh](https://github.com/caddy-dns/ovh): ACME DNS-01 challenges through the OVH API, for wildcard certificates or servers that can't be reached from the internet.
- [pberkel/caddy-storage-redis](https://github.com/pberkel/caddy-storage-redis): stores certificates and other data in Redis, so several Caddy instances can share them.

The image is rebuilt automatically when a new Caddy release comes out.

## Image

```
lordslair/caddy-ovh:latest
lordslair/caddy-ovh:<caddy-version>   # e.g. 2.11.7
```

It is a drop-in replacement for the official `caddy:<version>-alpine` image, with the same paths, entrypoint and config.

## Usage

Create an OVH API token with the rights the plugin needs: `GET`, `PUT`, `POST` and `DELETE` on `/domain/zone/*`. See the [caddy-dns/ovh README](https://github.com/caddy-dns/ovh) for details.

`Caddyfile`:

```caddyfile
{
	storage redis {
		host {$REDIS_HOST}
		port 6379
	}
}

*.example.com {
	tls {
		dns ovh {
			endpoint {$OVH_ENDPOINT}
			application_key {$OVH_APPLICATION_KEY}
			application_secret {$OVH_APPLICATION_SECRET}
			consumer_key {$OVH_CONSUMER_KEY}
		}
	}
	respond "Hello"
}
```

The `storage redis` block is optional. Without it, Caddy keeps its default file storage.

`compose.yaml`:

```yaml
services:
  caddy:
    image: lordslair/caddy-ovh:latest
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    environment:
      OVH_ENDPOINT: ovh-eu
      OVH_APPLICATION_KEY: ...
      OVH_APPLICATION_SECRET: ...
      OVH_CONSUMER_KEY: ...
      REDIS_HOST: redis
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
  caddy_config:
```

To check which plugins are built in:

```sh
docker run --rm lordslair/caddy-ovh caddy list-modules | grep -E 'dns.providers.ovh|caddy.storage.redis'
```

## Building locally

```sh
docker build --build-arg CADDY_VERSION=2.11.7 -t caddy-ovh .
```

`CADDY_VERSION` must match an existing `caddy:<version>-builder-alpine` tag. It defaults to `2.11`.

## How the automatic builds work

[`.github/workflows/build-on-release.yml`](.github/workflows/build-on-release.yml) runs every day at midnight UTC, and you can also start it by hand from the Actions tab. It:

1. Gets the latest Caddy release tag from GitHub.
2. Builds the image with that version and pushes it as `latest` and `<version>`.
3. Re-enables itself through the GitHub API. Without this step, GitHub turns off scheduled workflows after 60 days with no activity on the repository.

The workflow needs these settings:

| Name              | Kind     | Value                    |
|-------------------|----------|--------------------------|
| `DOCKER_USERNAME` | variable | Docker Hub username      |
| `DOCKER_PASSWORD` | secret   | Docker Hub access token  |

## License

[MIT](LICENSE)
