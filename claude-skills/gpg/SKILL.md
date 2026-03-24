---
name: gpg
description: Use this skill when the user asks about GPG key cache status, GPG signing issues, git commit hanging or failing due to GPG, passphrase expiry, or gpg-agent troubleshooting. Keywords: gpg, gpg-agent, signing key, passphrase, cached, expired, keygrip, git commit hang.
---

# GPG Signing Key Management

This project uses GPG to sign git commits. The signing key must have its passphrase cached in `gpg-agent` before committing, or the commit will hang.

## Key Information

To look up the key details, run:

```bash
gpg --with-keygrip --list-secret-keys
```

Example output:
```
sec   ed25519 2025-01-01 [SC]
      AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA      ← fingerprint
      Keygrip = BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  ← keygrip (used by gpg-agent)
uid           [ unknown] Your Name <you@example.com>
ssb   cv25519 2025-01-01 [E]
      Keygrip = CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC  ← encryption subkey keygrip
```

> **Fingerprint vs Keygrip**: `gpg-connect-agent keyinfo --list` reports **keygrips**, not fingerprints. Keygrips are derived from raw key material and used internally by gpg-agent — they differ from the fingerprint shown in `gpg -K`.

Use the keygrip of the `[SC]` (signing) key in the commands below.

## Check Cache Status

Run this before any `git commit` (replace `<KEYGRIP>` with your signing key's keygrip):

```bash
gpg-connect-agent 'keyinfo --list' /bye | awk '/<KEYGRIP>/ {print ($7 == "1") ? "CACHED" : "EXPIRED"}'
```

- `CACHED` → safe to commit
- `EXPIRED` → follow the steps below before committing

## Fix: Passphrase Expired

1. **Extend cache TTL** in `~/.gnupg/gpg-agent.conf` (set to 1 year):
   ```
   default-cache-ttl 31536000
   max-cache-ttl 31536000
   ```

2. **Reload gpg-agent:**
   ```bash
   gpgconf --kill gpg-agent
   ```

3. **Prime the cache** by signing a test payload (this will prompt for the passphrase):
   ```bash
   echo "test" | gpg --clearsign > /dev/null
   ```

4. **Verify it's cached:**
   ```bash
   gpg-connect-agent 'keyinfo --list' /bye | awk '/<KEYGRIP>/ {print ($7 == "1") ? "CACHED" : "EXPIRED"}'
   ```

## Useful Diagnostics

```bash
# Show all keys with keygrips
gpg --with-keygrip --list-secret-keys

# Show raw agent key cache state (column 7: 1=cached, -=not cached)
gpg-connect-agent 'keyinfo --list' /bye

# Check gpg-agent config
cat ~/.gnupg/gpg-agent.conf
```
