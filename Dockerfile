# Cronicle for Railway: the official Cronicle release, built on the official Node.js image.
# Upstream: https://github.com/jhuckaby/Cronicle (no official Docker image is published upstream;
# the Docker Hub image cronicle/cronicle is the separate "Cronicle Edge" fork).
FROM node:24.22.3-trixie-slim@sha256:af02d57b57719b9657a45199a79264a9437940cd55b3c7b3fc99615654f124a0

ARG CRONICLE_VERSION=0.9.146
ARG CRONICLE_SHA256=01731d7b0e5c5b872f7b92d578039a1beee6531fb85b105690ccaf5f3c65fb3f

# procps: Cronicle runs /bin/ps to track job CPU and memory.
# curl, ca-certificates, tzdata: handy for shell-script jobs and time zones.
RUN apt-get update \
 && apt-get install -y --no-install-recommends procps curl ca-certificates tzdata \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/cronicle
RUN curl -fsSL -o /tmp/cronicle.tar.gz "https://github.com/jhuckaby/Cronicle/archive/refs/tags/v${CRONICLE_VERSION}.tar.gz" \
 && echo "${CRONICLE_SHA256}  /tmp/cronicle.tar.gz" | sha256sum -c - \
 && tar xzf /tmp/cronicle.tar.gz --strip-components 1 \
 && rm /tmp/cronicle.tar.gz \
 && npm install --omit=dev --ignore-scripts --no-audit --no-fund \
 && node bin/build.js dist \
 && npm cache clean --force

COPY start.sh /usr/local/bin/cronicle-start
RUN chmod +x /usr/local/bin/cronicle-start

ENV PORT=3012
EXPOSE 3012
VOLUME ["/opt/cronicle/data"]

CMD ["/usr/local/bin/cronicle-start"]
