#!/usr/bin/env bash

set -e

echo "Starting dotfiles installation for GitHub Codespaces..."

# Get the dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"
if [ -d "/workspaces/.codespaces/.persistedshare/dotfiles" ]; then
    DOTFILES_DIR="/workspaces/.codespaces/.persistedshare/dotfiles"
fi

CODESPACES_DIR="$DOTFILES_DIR/codespaces"
SHARED_DIR="$DOTFILES_DIR/shared"
TIMESTAMP=$(date +%Y-%m-%d)

echo "Dotfiles directory: $DOTFILES_DIR"
echo "Codespaces config directory: $CODESPACES_DIR"

# Install Node.js if not present
echo ""
echo "Checking for Node.js..."
if command -v node &> /dev/null; then
    echo "✓ Node.js is already installed"
    echo "  Version: $(node --version)"
else
    echo "Node.js not found. Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "✓ Node.js installed successfully"
fi

# ==============================================================================
# SURGICAL APPROACH: Shell config (.bashrc) only
# ==============================================================================
echo ""
echo "Configuring shell (bash) - SURGICAL APPROACH..."

# Step 1: Copy our .bashrc.dotfiles to home directory
echo "Installing dotfiles shell configuration..."
if [ -f "$HOME/.bashrc.dotfiles" ]; then
    echo "Backing up existing .bashrc.dotfiles to .bashrc.dotfiles.backup.$TIMESTAMP"
    cp "$HOME/.bashrc.dotfiles" "$HOME/.bashrc.dotfiles.backup.$TIMESTAMP"
fi
cp "$CODESPACES_DIR/.bashrc.dotfiles" "$HOME/.bashrc.dotfiles"
echo "✓ Copied .bashrc.dotfiles to home directory"

# Step 2: Backup user's existing .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    if [ ! -f "$HOME/.bashrc.backup.$TIMESTAMP" ]; then
        echo "Creating backup: .bashrc.backup.$TIMESTAMP"
        cp "$HOME/.bashrc" "$HOME/.bashrc.backup.$TIMESTAMP"
    fi
else
    echo "No existing .bashrc found, will create new one"
    touch "$HOME/.bashrc"
fi

# Step 3: Append source line to user's .bashrc
SOURCE_LINE="source ~/.bashrc.dotfiles"
if grep -qF "$SOURCE_LINE" "$HOME/.bashrc" 2>/dev/null; then
    echo "✓ Dotfiles already sourced in .bashrc"
else
    echo "Appending source line to .bashrc..."
    echo "" >> "$HOME/.bashrc"
    echo "# Dotfiles configuration (added by install.sh)" >> "$HOME/.bashrc"
    echo "$SOURCE_LINE" >> "$HOME/.bashrc"
    echo "✓ Source line added to .bashrc"
fi

# ==============================================================================
# FULL REPLACEMENT: All other files (with timestamped backups)
# ==============================================================================
echo ""
echo "Installing other dotfiles - FULL REPLACEMENT with backups..."

# Backup and replace .aliases
if [ -f "$HOME/.aliases" ]; then
    echo "Backing up .aliases to .aliases.backup.$TIMESTAMP"
    cp "$HOME/.aliases" "$HOME/.aliases.backup.$TIMESTAMP"
fi
echo "Replacing .aliases..."
cp "$CODESPACES_DIR/.aliases.dotfiles" "$HOME/.aliases"
echo "✓ .aliases replaced"

# Backup and replace .gitconfig
if [ -f "$HOME/.gitconfig" ]; then
    echo "Backing up .gitconfig to .gitconfig.backup.$TIMESTAMP"
    cp "$HOME/.gitconfig" "$HOME/.gitconfig.backup.$TIMESTAMP"
fi
echo "Replacing .gitconfig..."
cp "$SHARED_DIR/.gitconfig" "$HOME/.gitconfig"
echo "✓ .gitconfig replaced"

# Install Claude Code
echo ""
echo "Installing Claude Code..."
if command -v claude &> /dev/null; then
    echo "✓ Claude Code is already installed"
else
    echo "Installing Claude Code via npm..."
    npm install -g @anthropic-ai/claude-code
    echo "✓ Claude Code installed successfully"
fi

# Verify Claude Code installation
if command -v claude &> /dev/null; then
    echo "✓ Claude Code version: $(claude --version 2>/dev/null || echo 'installed')"
else
    echo "⚠ Warning: Claude Code installation may have failed"
fi

# Install Happy Coder
echo ""
echo "Installing Happy Coder for mobile Claude Code control..."
if npm list -g happy-coder &> /dev/null; then
    echo "✓ Happy Coder is already installed"
else
    echo "Installing Happy Coder via npm..."
    npm install -g happy-coder
    echo "✓ Happy Coder installed successfully"
fi

# Configure Claude Code settings
echo ""
echo "Configuring Claude Code settings..."
if [ ! -d "$HOME/.claude" ]; then
    mkdir -p "$HOME/.claude"
fi

if [ -f "$SHARED_DIR/.claude-settings.json" ]; then
    if [ -f "$HOME/.claude/settings.json" ]; then
        echo "Backing up Claude settings to settings.json.backup.$TIMESTAMP"
        cp "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.backup.$TIMESTAMP"
    fi
    echo "Replacing Claude Code settings.json..."
    cp "$SHARED_DIR/.claude-settings.json" "$HOME/.claude/settings.json"
    echo "✓ Claude Code settings configured"
else
    echo "⚠ .claude-settings.json not found in shared/"
fi

# Configure ccstatusline
echo ""
echo "Configuring ccstatusline..."
if [ ! -d "$HOME/.config/ccstatusline" ]; then
    mkdir -p "$HOME/.config/ccstatusline"
fi

if [ -f "$SHARED_DIR/ccstatusline.settings.json" ]; then
    if [ -f "$HOME/.config/ccstatusline/settings.json" ]; then
        echo "Backing up ccstatusline settings to settings.json.backup.$TIMESTAMP"
        cp "$HOME/.config/ccstatusline/settings.json" "$HOME/.config/ccstatusline/settings.json.backup.$TIMESTAMP"
    fi
    echo "Replacing ccstatusline settings.json..."
    cp "$SHARED_DIR/ccstatusline.settings.json" "$HOME/.config/ccstatusline/settings.json"
    echo "✓ ccstatusline configured"
else
    echo "⚠ ccstatusline.settings.json not found in shared/"
fi

echo ""
echo "=========================================="
echo "✓ Codespaces dotfiles installation complete!"
echo "=========================================="
echo ""
echo "Installation Summary:"
echo "  SURGICAL (source line added):"
echo "    ~/.bashrc → sources ~/.bashrc.dotfiles"
echo ""
echo "  REPLACED (with timestamped backups):"
echo "    ~/.aliases"
echo "    ~/.gitconfig"
echo "    ~/.claude/settings.json"
echo "    ~/.config/ccstatusline/settings.json"
echo ""
echo "Backups created with timestamp: $TIMESTAMP"
echo ""
echo "Next Steps:"
echo ""
echo "1. Apply changes to your current shell:"
echo "   source ~/.bashrc"
echo ""
echo "2. Authenticate Claude Code:"
echo "   claude"
echo ""
echo "3. (Optional) Set up secrets via GitHub Codespaces:"
echo "   Go to https://github.com/settings/codespaces"
echo "   Use 'Codespaces secrets' to manage API keys"
echo ""
echo "📱 Push notifications are configured via Claude Code hooks."
echo "   See .docs/CLAUDE_NOTIFICATIONS_SETUP.md for setup instructions."
echo ""
