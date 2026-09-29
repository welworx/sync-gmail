FROM alpine:3.20

RUN apk add --no-cache imapsync ca-certificates

VOLUME /cache /logs

ENTRYPOINT ["imapsync", "--gmail1", "--gmail2"]
