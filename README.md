# Dotfiles for GitHub Codespaces & macOS

Automated shell configuration for consistent development environments.

## Quick Start

### GitHub Codespaces (Linux)

GitHub Codespaces automatically installs dotfiles:

1. Go to [Codespaces settings](https://github.com/settings/codespaces)
2. Enable "Automatically install dotfiles"
3. Select this repository

When you create a Codespace, `install.sh` runs automatically.

### macOS (Manual Installation)

Clone and run the installer once:

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles
./install-macos.sh
source ~/.bashrc
```

## Post-Installation Setup

After the installer completes, follow these steps:

### 1. Authenticate Claude Code

```bash
claude
```

Follow the interactive prompts to authenticate with your Anthropic API key.

### 2. Update Git Configuration

Edit `.gitconfig` and replace with your information:

```bash
[user]
    name = Your Name
    email = YOUR_ID+username@users.noreply.github.com
```

Get your GitHub no-reply email at: https://github.com/settings/emails

### 3. Configure Happy Server (for notifications)

**Option A: Use official Happy CLI (recommended)**
- Remove `HAPPY_SERVER_URL` from `.bashrc` (Codespaces) or `local-macos/.bashrc.macos` (macOS)
- Skip to step 4

**Option B: Use custom Happy deployment ([self-hosting guide](https://happy.engineering/docs/guides/self-hosting/))**
- Update `HAPPY_SERVER_URL` with your server URL in the same files

### 4. Set Up Notifications (optional)

If using Happy notifications:

1. Follow [CLAUDE_NOTIFICATIONS_SETUP.md](CLAUDE_NOTIFICATIONS_SETUP.md)
2. Register with Happy server
3. Install Happy mobile app
4. Connect your device

### 5. Reload Shell

```bash
source ~/.bashrc
```

You're ready to go! Claude Code will now send push notifications when it needs input or completes tasks.

## What's Included

**Shell Configuration:**
- Bash with custom aliases and functions
- Docker aliases and helper functions
- Git aliases (`co`, `br`, `pr`, `st`, `ld`, `ll`, etc.)

**Auto-Installed Tools:**
- [Homebrew](https://brew.sh/) (macOS only, if not present)
- [Node.js](https://nodejs.org/) (via Homebrew or apt)
- [Claude Code CLI](https://docs.claude.com/en/docs/claude-code/overview) - AI coding assistant
- [Happy Coder CLI](https://github.com/slopus/happy-cli) - Push notifications
- [ccstatusline](https://github.com/sirmalloc/ccstatusline) - Claude Code status line

**Features:**
- Push notifications when Claude Code needs input or completes tasks
- GitHub privacy protection (uses no-reply email)
- Separate configurations for Codespaces (Linux) and macOS

## Ongoing Customization

### Add to PATH

**Codespaces:** Edit `.bashrc`
**macOS:** Edit `local-macos/.bashrc.macos`

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Add Aliases

**Codespaces:** Edit `.aliases`
**macOS:** Edit `local-macos/.aliases.macos`

```bash
alias gp='git push'
```

### Add Environment Variables

**Codespaces:** Edit `.bashrc`
**macOS:** Edit `local-macos/.bashrc.macos`

```bash
export MY_VAR="value"
```

⚠️ Never commit secrets! Use `.env` files (ignored by git).

### Add Functions

**Codespaces:** Edit `.aliases`
**macOS:** Edit `local-macos/.aliases.macos`

```bash
function gcp() {
    git add -A && git commit -m "$1" && git push
}
```

### Environment-Specific Config

**Codespaces:** Edit `.bashrc`
**macOS:** Edit `local-macos/.bashrc.macos`

Add configuration that only runs in specific environments:

**Codespaces detection:**
```bash
if [ "$CODESPACES" = "true" ]; then
    export CODESPACE_SPECIFIC="value"
fi
```

**macOS detection:**
```bash
if [ "$(uname)" = "Darwin" ]; then
    export MAC_SPECIFIC="value"
fi
```

**Use cases:**
- Different API endpoints for development vs production
- Platform-specific tool paths
- Environment-specific debug settings

### Auto-Install Tools

**Codespaces:** Edit `install.sh`
**macOS:** Edit `install-macos.sh`
```bash
brew install your-tool
npm install -g your-package
```

## Troubleshooting

**Codespaces not applying dotfiles:**
Check [settings](https://github.com/settings/codespaces) and logs at `/workspaces/.codespaces/.persistedshare/creation.log`

**Claude Code not found:**
```bash
npm list -g @anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code  # reinstall
```

**Authentication:**
Run `claude` and follow prompts.

## Structure

```
dotfiles/
├── .bashrc                   # Codespaces
├── .aliases                  # Codespaces
├── .gitconfig                # Both
├── install.sh                # Codespaces
├── install-macos.sh          # macOS
├── local-macos/
│   ├── .bashrc.macos         # macOS
│   └── .aliases.macos        # macOS
└── .claude-settings.json     # Claude Code config
```

## Resources

- [GitHub Codespaces Docs](https://docs.github.com/en/codespaces)
- [Claude Code Docs](https://docs.claude.com/en/docs/claude-code/overview)
- [Dotfiles Guide](https://dotfiles.github.io/)
