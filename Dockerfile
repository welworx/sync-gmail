FROM alpine:3.22@sha256:5291449c3df73caf6ed85e649dec1b9e818b39a5d8c871e97afc13e9cd5e8fa8

RUN apk add --no-cache imapsync ca-certificates && \
    adduser -D imapsync

# imapsync detects "Docker context" (disables file logging by default, see
# README) by checking for /Dockerfile — the same trick its own upstream
# image uses: https://imapsync.lamiral.info/INSTALL.d/Dockerfile
COPY Dockerfile /Dockerfile

RUN mkdir -p /cache /logs && chown imapsync:imapsync /cache /logs
VOLUME /cache /logs
USER imapsync

ENTRYPOINT ["imapsync", "--gmail1", "--gmail2"]
