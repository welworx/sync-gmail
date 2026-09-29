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

The entrypoint always passes `--gmail1 --gmail2`, imapsync's built-in Gmail
preset (sets host/SSL, label sync, cross-duplicate skipping, etc. — see
[FAQ.Gmail.txt](https://imapsync.lamiral.info/FAQ.d/FAQ.Gmail.txt)), so
there's no need to set `--host1`/`--host2` yourself.

Any extra `imapsync` flag can be appended the same way (`--dry`, `--justfolders`, etc.) — the entrypoint is exec-form, `docker run` args are simply appended to it.

## Gmail bandwidth limits

Gmail throttles IMAP transfer, not imapsync-specific but hit during any
large sync — see [Gmail bandwidth
limits](https://knowledge.workspace.google.com/admin/gmail/gmail-bandwidth-limits):

- IMAP download: 2500 MB/day, IMAP upload: 500 MB/day, per account.
- Exceeding the limit suspends the account for 1-24 hours (sign-in error
  until it resets).
- Google recommends throttling instead: `--maxbytespersecond <n>` (the
  `--gmail1`/`--gmail2` preset already sets `300_000`) and running large
  migrations in smaller chunks (e.g. `--folder`/`--maxage`) rather than one
  continuous transfer.

## "All Mail" and labels

Gmail IMAP exposes labels as folders, so `[Gmail]/All Mail` contains every
message regardless of label — a message with no label (e.g. archived, never
filed) only shows up there, not in any other folder.

## Credentials as files

`--password1`/`--password2` end up in `docker inspect`, `ps`, and shell
history. `--passfile1 <path>`/`--passfile2 <path>` read the password from
the first line of a file instead:

```bash
docker run --rm \
  -v /path/to/password1.txt:/run/secrets/password1:ro \
  -v /path/to/password2.txt:/run/secrets/password2:ro \
  ghcr.io/welworx/sync-gmail \
  --user1 source@gmail.com --passfile1 /run/secrets/password1 \
  --user2 dest@gmail.com   --passfile2 /run/secrets/password2
```

Or set them via env instead — imapsync reads `IMAPSYNC_PASSWORD1`/
`IMAPSYNC_PASSWORD2` natively when `--password1`/`--passfile1` (or
`--password2`/`--passfile2`) aren't given:

```bash
docker run --rm \
  -e IMAPSYNC_PASSWORD1='app-password' \
  -e IMAPSYNC_PASSWORD2='app-password' \
  ghcr.io/welworx/sync-gmail \
  --user1 source@gmail.com --user2 dest@gmail.com
```

## Logs

imapsync disables file logging by default when it detects a Docker context
(stdout only). Pass `--log --logdir /logs` with a mounted volume to keep a
persistent log file per run (`/logs/LOG_imapsync/<timestamp>_user1_user2.txt`):

```bash
docker run --rm -v sync-gmail-logs:/logs ghcr.io/welworx/sync-gmail \
  --user1 source@gmail.com --password1 'app-password' \
  --user2 dest@gmail.com   --password2 'app-password' \
  --log --logdir /logs
```

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
