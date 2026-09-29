# sync-gmail

Minimal [imapsync](https://imapsync.lamiral.info/) container, defaulted to
Gmail on both ends (`--gmail1 --gmail2` baked into the entrypoint — no need
to set `--host1`/`--host2` yourself).

Published as `ghcr.io/welworx/sync-gmail:latest` (amd64 + arm64). GHCR
packages are private on first push — set it public in the package's GitHub
settings, or `docker login ghcr.io` first.

## Usage

Full example, German→English Gmail sync, with the flags worth using by default:

```bash
docker run --rm -v sync-gmail-cache:/cache ghcr.io/welworx/sync-gmail \
  --user1 source@gmail.com --password1 'app-password-1' \
  --user2 dest@gmail.com   --password2 'app-password-2' \
  --useuid --usecache --tmpdir /cache --maxsleep 30 \
  --folderlast "[Gmail]/Gesendet" --folderlast "[Gmail]/Papierkorb" \
  --folderlast "[Gmail]/Wichtig" --folderlast "[Gmail]/Markiert" \
  --folderlast "[Gmail]/Entwürfe" --folderlast "[Gmail]/Spam" \
  --folderlast "[Gmail]/Alle Nachrichten" \
  --f1f2 "[Gmail]/Markiert=[Gmail]/Starred"
```

- Gmail requires an [app password](https://myaccount.google.com/apppasswords) (2FA) or OAuth2 — a plain account password won't authenticate.
- `-v sync-gmail-cache:/cache` + `--tmpdir /cache --usecache`: persists imapsync's UID cache across runs, so re-runs skip already-synced messages instead of re-checking every message on both servers.
- `--useuid --maxsleep 30`: UID-based dedup (more reliable than the header-based default) and a higher sleep ceiling (default is 2s) so the Gmail preset's bandwidth throttling can actually back off.
- `--folderlast`/`--f1f2`: fixes German folder names the image's Gmail preset doesn't recognize — see [Known limitations](#known-limitations). Swap the German strings to whichever side (`host1`/`host2`) is actually the German-locale account; drop both flags entirely if neither account is German-locale.

Any other `imapsync` flag can be appended the same way — the entrypoint is exec-form, `docker run` args are simply appended to it.

## Known limitations

- **Gmail bandwidth limits**: 2500MB/day IMAP download, 500MB/day upload, per account — exceeding it suspends the account for 1-24h. See [Google's docs](https://knowledge.workspace.google.com/admin/gmail/gmail-bandwidth-limits). The Gmail preset already sets `--maxbytespersecond 300_000`; lower it further if you still hit the limit.
- **"All Mail" contains everything**: Gmail exposes labels as IMAP folders; a message with no label only shows up in `[Gmail]/All Mail`.
- **Non-English folder names**: the baked-in Gmail preset's folder-ordering list is hardcoded English, and imapsync's folder auto-mapping has built-in strings for German Sent/Trash/Drafts but not Starred/Archive — use `--folderlast`/`--f1f2` as shown above for other locales/folders.
- **`--skipcrossduplicates` is deliberately not used above**: per imapsync's own docs it's meant for Gmail→non-Gmail migrations and defaults off for Gmail→Gmail (label sync needs to visit each label-folder). Only add it if the destination isn't Gmail.
- **Vulnerability scanning is amd64-only**: the CI build is multi-arch, but the scan step can't load a multi-platform image locally; arm64 uses identical package versions.

## More settings

Everything else — persistent logs (`--log --logdir <dir>` + a mounted
volume, off by default under Docker), credentials from a file or env var
instead of `--password1`/`--password2` (`--passfile1`/`--passfile2`,
`IMAPSYNC_PASSWORD1`/`IMAPSYNC_PASSWORD2`), and the full flag reference —
see the [imapsync manual](https://imapsync.lamiral.info/README.txt) and
[Gmail FAQ](https://imapsync.lamiral.info/FAQ.d/FAQ.Gmail.txt).
