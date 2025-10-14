# Claude Code Notifications Setup

This dotfiles configuration includes push notifications for Claude Code using **Happy Coder CLI**.

## How It Works

Claude Code hooks send push notifications to your phone via Happy Coder when:
- **Notification hook**: Claude needs your input (high priority 🔔)
- **Stop hook**: A task completes (normal priority ✅)

## What's Installed

The installation scripts automatically install:
- **Happy Coder CLI** (`@happy-coder/cli`) - Notification tool
- **.claude-settings.json** - Pre-configured hooks

No additional manual installation needed!

## Setup Instructions

### 1. Choose Your Happy Server

**Option A: Official Happy CLI (Recommended)**

No configuration needed! The official Happy CLI automatically uses the default Happy server.

**To use the official Happy CLI:**
1. Remove `HAPPY_SERVER_URL` from `.bashrc` (Codespaces) or `local-macos/.bashrc.macos` (macOS)
2. The Happy CLI will use its default server automatically

**Option B: Custom Happy Server Deployment**

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
```bash
# Test high-priority notification
npx -y @happy-coder/cli send "🔔 Test notification from Claude Code" --priority high

# Test normal notification
npx -y @happy-coder/cli send "✅ Test complete"
```

You should receive push notifications on your mobile device.

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

Example customization in `.claude-settings.json`:
```json
{
  "hooks": {
    "notification": {
      "type": "command",
      "command": "npx -y @happy-coder/cli send '🔔 Claude needs your attention!' --priority high"
    },
    "stop": {
      "type": "command",
      "command": "npx -y @happy-coder/cli send '✅ Task completed successfully!'"
    }
  }
}
```

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
