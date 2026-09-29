FROM alpine:3.20

RUN apk add --no-cache imapsync ca-certificates

VOLUME /cache /logs

ENTRYPOINT ["imapsync", "--host1", "imap.gmail.com", "--ssl1", "--host2", "imap.gmail.com", "--ssl2"]
