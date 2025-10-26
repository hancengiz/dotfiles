# Claude Code Notifications Setup

This dotfiles configuration includes push notifications for Claude Code using **Happy Coder**.

## How It Works

Claude Code hooks send notifications when:
- **Notification hook**: Claude needs your input (high priority 🔔)
  - Local macOS notification via terminal-notifier
  - Mobile push notification via Happy Coder
- **Stop hook**: A task completes (normal priority ✅)
  - Local macOS notification via terminal-notifier
  - Mobile push notification via Happy Coder

## What's Installed

The installation scripts automatically install:
- **terminal-notifier** (macOS only) - Local macOS notifications (works offline)
- **Happy Coder** (`happy-coder`) - Mobile Claude Code control and notification tool
- **Platform-specific .claude-settings.json**:
  - macOS: Uses both terminal-notifier and Happy
  - Codespaces/Linux: Uses Happy only

No additional manual installation needed!

## Setup Instructions

### 1. Choose Your Happy Server

**Option A: Official Happy CLI (Recommended)**

No configuration needed! The official Happy CLI automatically uses the default Happy server.

**To use the official Happy CLI:**
1. Remove `HAPPY_SERVER_URL` from `.bashrc` (Codespaces) or `local-macos/.bashrc.macos` (macOS)
2. The Happy CLI will use its default server automatically

**Option B: Custom Happy Server Deployment ([self-hosting guide](https://happy.engineering/docs/guides/self-hosting/))**

This repository is pre-configured with a custom Happy server deployment:
```bash
export HAPPY_SERVER_URL="https://happy-cengiz.up.railway.app"
```

This is for the repository maintainer's custom deployment. **You should use the official Happy CLI (Option A) unless you have your own Happy server deployment.**

**If you have your own Happy server:**
1. Update `HAPPY_SERVER_URL` in `.bashrc` (Codespaces) or `local-macos/.bashrc.macos` (macOS)
2. Reload your shell: `source ~/.bashrc`

### 2. Register with Happy Server

**For official Happy CLI:** Follow the Happy CLI setup instructions for registration.

**For custom Happy server:** Go to your Happy server URL, complete registration, and get your channel ID.

### 3. Install Happy Mobile App

Download the Happy app on your mobile device and follow the setup instructions.

### 4. Connect Your Device

Follow the Happy setup instructions to connect your mobile device to your channel.

### 5. Test Your Setup

Test your notifications:

**Local macOS notifications (always work, even offline):**
```bash
# Test notification
terminal-notifier -title "Claude Code" -message "🧪 Test notification" -sound default
```

**Mobile push notifications (requires Happy server):**
```bash
# Test high-priority notification
npx -y happy-coder send "🔔 Test notification from Claude Code" --priority high

# Test normal notification
npx -y happy-coder send "✅ Test complete"
```

You should receive:
- A macOS notification immediately (terminal-notifier)
- A push notification on your mobile device (Happy Coder)

## Security Note

- Channel IDs are unique to your registration with Happy server
- Only you can receive notifications on your channel
- The Happy server URL can be changed if you want to use a different instance
- See Happy server documentation for more details

## Customization

You can customize the hooks in `.claude-settings.json`:
- Change message text
- Adjust priority levels
- Modify notification timing
- Add custom messages for different events
- Enable/disable specific notification channels

Example customization in `.claude-settings.json`:
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "terminal-notifier -title \"Claude Code\" -message \"🔔 Custom message\" -sound default 2>/dev/null || true"
          },
          {
            "type": "command",
            "command": "happy notify -p \"🔔 Custom message\" 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

**Note:** The current setup includes both local (terminal-notifier) and remote (Happy) notifications. You can:
- Remove the Happy command to only use local macOS notifications
- Remove the terminal-notifier command to only use mobile push notifications
- Keep both for maximum reliability

## Using a Different Happy Server

To use a different Happy server instance:

1. Update the `HAPPY_SERVER_URL` in:
   - `.bashrc` (for Codespaces)
   - `local-macos/.bashrc.macos` (for macOS)

2. Register with your new server instance

3. Update your mobile app configuration to point to the new server

## Alternative Notification Services

While this configuration uses Happy server, you can also configure:
- **Slack**: Webhook URL
- **Discord**: Webhook URL
- **Telegram**: Bot API
- **Other custom webhooks**

Just replace the command in the hooks configuration with your preferred notification method.
