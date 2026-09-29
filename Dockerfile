FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends imapsync ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["imapsync", "--host1", "imap.gmail.com", "--ssl1", "--host2", "imap.gmail.com", "--ssl2"]
