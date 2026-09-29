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
