FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

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
