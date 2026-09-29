# sync-gmail

Minimal [imapsync](https://imapsync.lamiral.info/) container, defaulted to Gmail on both ends.

Published as `ghcr.io/welworx/sync-gmail:latest`.

## Usage

```bash
docker run --rm ghcr.io/welworx/sync-gmail \
  --user1 source@gmail.com --password1 'app-password' \
  --user2 dest@gmail.com   --password2 'app-password'
```

Gmail requires an [app password](https://myaccount.google.com/apppasswords) (2FA account) or OAuth2 — plain account passwords won't authenticate.

Any extra `imapsync` flag can be appended the same way (`--dry`, `--justfolders`, etc.).

## Reusable cache across runs

`--usecache` makes imapsync remember which message UIDs it already synced
(one empty marker file per message under `<tmpdir>/imapsync_cache/`), so
re-runs skip already-copied messages instead of re-checking them on both
servers. Without a persistent `--tmpdir`, that cache lives in the
container's own filesystem and is lost when the container exits.

Mount a volume at `/cache` (declared in the image) and point `--tmpdir` at
it to keep the cache between runs:

```bash
docker run --rm -v sync-gmail-cache:/cache ghcr.io/welworx/sync-gmail \
  --user1 source@gmail.com --password1 'app-password' \
  --user2 dest@gmail.com   --password2 'app-password' \
  --tmpdir /cache --usecache
```
