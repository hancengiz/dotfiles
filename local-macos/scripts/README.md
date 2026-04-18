# scripts — manual-run utilities

Standalone macOS scripts you invoke on demand. Nothing here is scheduled or
installed by `install-macos.sh` — run them directly when needed.

For scheduled jobs (LaunchAgents and their scripts), see `../launchd/`.

## Scripts

### `set-zed-defaults.sh`

Sets Zed as the default macOS app for coding-related file extensions via
`duti`. Rerun after Antigravity / Cursor / VS Code updates re-claim defaults
via `LSHandlerRank`.

**Prereq:** `brew install duti`

**Run:**

```sh
~/code/dotfiles/local-macos/scripts/set-zed-defaults.sh
```
