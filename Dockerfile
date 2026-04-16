# Default to 2.11 if no ARG is passed
ARG CADDY_VERSION=2.11

# 1. Use a specific version for build stability
FROM caddy:${CADDY_VERSION}-builder-alpine AS builder

# 2. Build the binary
RUN xcaddy build --with github.com/caddy-dns/ovh

# 3. Use a clean, tiny base for the final image
FROM caddy:${CADDY_VERSION}-alpine

# 4. Meta-information (Optional but helpful)
LABEL maintainer="lordslair"
LABEL description="Caddy with OVH DNS plugin"
LABEL version="${CADDY_VERSION}"

# 5. Copy the custom binary
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
