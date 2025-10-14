#!/usr/bin/env bash

set -e

echo "Starting dotfiles installation for GitHub Codespaces..."

# Get the dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"
if [ -d "/workspaces/.codespaces/.persistedshare/dotfiles" ]; then
    DOTFILES_DIR="/workspaces/.codespaces/.persistedshare/dotfiles"
fi

echo "Dotfiles directory: $DOTFILES_DIR"

# Create symlinks for dotfiles
echo "Creating symlinks for dotfiles..."
for file in "$DOTFILES_DIR"/.{bashrc,aliases,gitconfig}; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target="$HOME/$filename"

        # Backup existing file if it exists
        if [ -f "$target" ] && [ ! -L "$target" ]; then
            echo "Backing up existing $filename to ${filename}.backup"
            mv "$target" "${target}.backup"
        fi

        # Create symlink
        echo "Linking $filename"
        ln -sf "$file" "$target"
    fi
done

echo "Dotfiles symlinked successfully"

# Install Claude Code
echo "Installing Claude Code..."
if command -v claude &> /dev/null; then
    echo "Claude Code is already installed"
else
    echo "Installing Claude Code via npm..."
    if command -v npm &> /dev/null; then
        npm install -g @anthropic-ai/claude-code
        echo "Claude Code installed successfully"
    else
        echo "npm not found. Installing Node.js and npm..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
        npm install -g @anthropic-ai/claude-code
        echo "Claude Code installed successfully"
    fi
fi

# Verify Claude Code installation
if command -v claude &> /dev/null; then
    echo "Claude Code version: $(claude --version 2>/dev/null || echo 'installed')"
else
    echo "Warning: Claude Code installation may have failed"
fi

# Install Happy Coder CLI
echo ""
echo "Installing Happy Coder CLI for push notifications..."
if npm list -g @happy-coder/cli &> /dev/null; then
    echo "✓ Happy Coder CLI is already installed"
else
    echo "Installing Happy Coder CLI via npm..."
    npm install -g @happy-coder/cli
    echo "✓ Happy Coder CLI installed successfully"
fi

# Configure Claude Code settings
echo ""
echo "Configuring Claude Code settings..."
if [ ! -d "$HOME/.claude" ]; then
    mkdir -p "$HOME/.claude"
fi

if [ -f "$DOTFILES_DIR/.claude-settings.json" ]; then
    echo "Setting up Claude Code settings.json..."
    cp "$DOTFILES_DIR/.claude-settings.json" "$HOME/.claude/settings.json"
    echo "✓ Claude Code settings configured"
else
    echo "⚠ .claude-settings.json not found in dotfiles"
fi

# Configure ccstatusline
echo ""
echo "Configuring ccstatusline..."
if [ ! -d "$HOME/.config/ccstatusline" ]; then
    mkdir -p "$HOME/.config/ccstatusline"
fi

if [ -f "$DOTFILES_DIR/ccstatusline.settings.json" ]; then
    echo "Setting up ccstatusline settings.json..."
    cp "$DOTFILES_DIR/ccstatusline.settings.json" "$HOME/.config/ccstatusline/settings.json"
    echo "✓ ccstatusline configured"
else
    echo "⚠ ccstatusline.settings.json not found in dotfiles"
fi

echo ""
echo "Dotfiles installation complete!"
echo ""
echo "To apply changes to your current shell, run:"
echo "  source ~/.bashrc"
echo ""
echo "Claude Code is installed. To authenticate, run:"
echo "  claude"
echo ""
echo "Claude Code will guide you through the authentication process."
echo ""
echo "📱 Push notifications are configured via Claude Code hooks."
echo "   See docs/CLAUDE_NOTIFICATIONS_SETUP.md for setup instructions."
