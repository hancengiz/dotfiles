#!/usr/bin/env bash

set -e

echo "Starting dotfiles installation for macOS..."

# Get the dotfiles directory (where this script is located)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACOS_DIR="$DOTFILES_DIR/local-macos"
SHARED_DIR="$DOTFILES_DIR/shared"
TIMESTAMP=$(date +%Y%m%d_%H%M%S_%3N)

echo "Dotfiles directory: $DOTFILES_DIR"
echo "macOS config directory: $MACOS_DIR"

# Verify macOS
if [ "$(uname)" != "Darwin" ]; then
    echo "Error: This script is for macOS only. Detected: $(uname)"
    exit 1
fi

echo "✓ macOS detected"

# Install Homebrew if not present
echo ""
echo "Checking for Homebrew..."
if command -v brew &> /dev/null; then
    echo "✓ Homebrew is already installed"
    echo "  Version: $(brew --version | head -n 1)"
else
    echo "Homebrew not found. Installing Homebrew..."
    echo "  This may take a few minutes and will require your password..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for current session
    if [ -d "/opt/homebrew/bin" ]; then
        # Apple Silicon
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo "✓ Homebrew installed (Apple Silicon)"
    elif [ -d "/usr/local/bin/brew" ]; then
        # Intel Mac
        eval "$(/usr/local/bin/brew shellenv)"
        echo "✓ Homebrew installed (Intel Mac)"
    else
        echo "⚠ Warning: Homebrew installation completed but brew command not found"
        echo "  You may need to restart your terminal"
    fi
fi

# Install Powerlevel10k
echo ""
echo "Installing Powerlevel10k theme..."
if brew list powerlevel10k &> /dev/null; then
    echo "✓ Powerlevel10k is already installed"
else
    echo "Installing Powerlevel10k via Homebrew..."
    brew install powerlevel10k
    echo "✓ Powerlevel10k installed successfully"
fi

# Install Node.js if not present
echo ""
echo "Checking for Node.js..."
if command -v node &> /dev/null; then
    echo "✓ Node.js is already installed"
    echo "  Version: $(node --version)"
else
    echo "Node.js not found. Installing Node.js via Homebrew..."
    brew install node
    echo "✓ Node.js installed successfully"
fi

# ==============================================================================
# SURGICAL APPROACH: Shell config (.zshrc) only
# ==============================================================================
echo ""
echo "Configuring shell (zsh) - SURGICAL APPROACH..."

# Step 1: Copy our .zshrc.dotfiles to home directory
echo "Installing dotfiles shell configuration..."
if [ -f "$HOME/.zshrc.dotfiles" ]; then
    echo "Backing up existing .zshrc.dotfiles to .zshrc.dotfiles.backup.$TIMESTAMP"
    cp "$HOME/.zshrc.dotfiles" "$HOME/.zshrc.dotfiles.backup.$TIMESTAMP"
fi
cp "$MACOS_DIR/.zshrc.dotfiles" "$HOME/.zshrc.dotfiles"
echo "✓ Copied .zshrc.dotfiles to home directory"

# Step 2: Backup user's existing .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    if [ ! -f "$HOME/.zshrc.backup.$TIMESTAMP" ]; then
        echo "Creating backup: .zshrc.backup.$TIMESTAMP"
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$TIMESTAMP"
    fi
else
    echo "No existing .zshrc found, will create new one"
    touch "$HOME/.zshrc"
fi

# Step 3: Append source line to user's .zshrc
SOURCE_LINE="source ~/.zshrc.dotfiles"
if grep -qF "$SOURCE_LINE" "$HOME/.zshrc" 2>/dev/null; then
    echo "✓ Dotfiles already sourced in .zshrc"
else
    echo "Appending source line to .zshrc..."
    echo "" >> "$HOME/.zshrc"
    echo "# Dotfiles configuration (added by install-macos.sh)" >> "$HOME/.zshrc"
    echo "$SOURCE_LINE" >> "$HOME/.zshrc"
    echo "✓ Source line added to .zshrc"
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
cp "$MACOS_DIR/.aliases.dotfiles" "$HOME/.aliases"
echo "✓ .aliases replaced"

# Backup and replace .p10k.zsh
if [ -f "$MACOS_DIR/.p10k.zsh" ]; then
    if [ -f "$HOME/.p10k.zsh" ]; then
        echo "Backing up .p10k.zsh to .p10k.zsh.backup.$TIMESTAMP"
        cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.backup.$TIMESTAMP"
    fi
    echo "Replacing .p10k.zsh..."
    cp "$MACOS_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
    echo "✓ .p10k.zsh replaced"
else
    echo "⚠ Warning: .p10k.zsh not found in $MACOS_DIR"
fi

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
echo "✓ macOS dotfiles installation complete!"
echo "=========================================="
echo ""
echo "Installation Summary:"
echo "  SURGICAL (source line added):"
echo "    ~/.zshrc → sources ~/.zshrc.dotfiles"
echo ""
echo "  REPLACED (with timestamped backups):"
echo "    ~/.aliases"
echo "    ~/.p10k.zsh"
echo "    ~/.gitconfig"
echo "    ~/.claude/settings.json"
echo "    ~/.config/ccstatusline/settings.json"
echo ""
echo "Backups created with timestamp: $TIMESTAMP"
echo ""
echo "Next Steps:"
echo ""
echo "1. Apply changes to your current shell:"
echo "   source ~/.zshrc"
echo ""
echo "2. Authenticate Claude Code:"
echo "   claude"
echo ""
echo "3. (Optional) Set up push notifications:"
echo "   happy auth login [--force]"
echo "   Follow the prompts to authenticate with Happy Coder"
echo "   See .docs/CLAUDE_NOTIFICATIONS_SETUP.md for details"
echo ""
echo "4. (Optional) Create ~/.secrets.zsh for API keys:"
echo "   This file is automatically sourced and ignored by git"
echo "   See README.md for setup instructions"
echo ""
echo "5. (Optional) Customize Powerlevel10k theme:"
echo "   p10k configure"
echo "   (A default theme is already configured)"
echo ""
