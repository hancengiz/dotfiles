# launchd — scheduled jobs

User-level macOS LaunchAgents and their scripts. Everything here is installed by
`install-macos.sh` and runs in the user's gui domain (not as root).

## Files

| File | Purpose |
|------|---------|
| `screenshots-archive.sh` | Moves old screenshots out of the active folder and evicts them from local disk |
| `com.cengiz.screenshots-archive.plist.template` | LaunchAgent that runs the script daily |

## How install wires it up

`install-macos.sh` does the following for each job here:

1. Marks the script executable in-place (no copy — scripts run straight from
   the dotfiles repo).
2. Substitutes `__HOME__` with `$HOME` and `__DOTFILES_DIR__` with the dotfiles
   clone path in the plist template, writing the result to
   `~/Library/LaunchAgents/<label>.plist`.
3. `launchctl bootout` the old instance (if any), then `launchctl bootstrap`
   the new one into `gui/<uid>`.

Paths in templates use `__HOME__` and `__DOTFILES_DIR__` placeholders so the
same plist works on any Mac regardless of where the repo is cloned.

## Jobs

### screenshots-archive (`com.cengiz.screenshots-archive`)

**What it does.** Moves files older than 24 hours from `~/Desktop/screenshots`
to `~/Desktop/screenshots-archive`, then calls `brctl evict` on each moved file
so iCloud drops the local copy and keeps only the cloud placeholder.

**Why this exists.** With iCloud's "Optimize Mac Storage" on, macOS sometimes
evicts recent CleanShot captures that are still in active use, forcing a
download when reopening them. This job keeps the last 24h of screenshots
pinned locally (via Finder's "Keep Downloaded" on `~/Desktop/screenshots`) and
deterministically offloads older ones on a schedule instead of leaving it to
macOS's opaque heuristics.

**Schedule.** Daily at 03:00 local time.

**Prerequisite.** Mark `~/Desktop/screenshots` as **Keep Downloaded** in
Finder (right-click → Keep Downloaded). Without this, iCloud may evict
recent files before the 24h window, defeating the point.

**Environment overrides.** The script honors these vars; defaults shown:

```
SCREENSHOTS_SRC=$HOME/Desktop/screenshots
SCREENSHOTS_DST=$HOME/Desktop/screenshots-archive
SCREENSHOTS_LOG=$HOME/Library/Logs/screenshots-archive.log
SCREENSHOTS_THRESHOLD_MIN=1440
```

To change the schedule or paths for this machine only, edit the installed
copy at `~/Library/LaunchAgents/com.cengiz.screenshots-archive.plist` and
reload. To change for every machine, edit the template here and re-run
`install-macos.sh`.

**Log.** `~/Library/Logs/screenshots-archive.log` (plus `.stdout.log` /
`.stderr.log` from launchd itself).

## Operating the jobs

```sh
# Run the script ad-hoc (same as the daily trigger)
~/code/dotfiles/local-macos/launchd/screenshots-archive.sh

# Force the LaunchAgent to fire now instead of waiting for 03:00
launchctl kickstart gui/$(id -u)/com.cengiz.screenshots-archive

# Check it's loaded
launchctl list | grep screenshots-archive

# Unload (stop the schedule)
launchctl bootout gui/$(id -u)/com.cengiz.screenshots-archive

# Reload after editing the plist
launchctl bootout gui/$(id -u)/com.cengiz.screenshots-archive || true
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.cengiz.screenshots-archive.plist

# Tail the log
tail -f ~/Library/Logs/screenshots-archive.log
```

## Adding a new scheduled job

1. Drop the script in this folder.
2. Add a plist template alongside it. Use `__DOTFILES_DIR__/local-macos/launchd/<script>.sh`
   in `ProgramArguments` and `__HOME__` for any other home-relative paths
   (logs, etc.).
3. Add a new install block in `install-macos.sh` following the pattern used
   for screenshots-archive (chmod → substitute → bootout → bootstrap).
4. Document it in this README under **Jobs**.
