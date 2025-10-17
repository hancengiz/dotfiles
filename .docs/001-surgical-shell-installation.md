# ADR 001: Surgical Shell Installation

**Status:** Accepted
**Date:** 2025-10-15
**Implemented:** 2025-10-17
**Decision Makers:** Cengiz Han
**Technical Story:** Support both macOS (zsh) and Codespaces (bash) with environment-specific shell configurations

---

## Context

The dotfiles repository needs to support two distinct environments with different shell requirements:

1. **macOS** - Uses zsh as the default shell with Powerlevel10k theme
2. **GitHub Codespaces** - Uses bash for cloud development environment

### Problem

Current approach incorrectly uses bashrc for both environments, but:
- macOS Catalina+ uses **zsh** as the default shell, not bash
- Codespaces uses **bash** as the default shell
- Shell configurations are fundamentally different between these environments
- Local macOS users have existing configurations that must be preserved

### User Requirements

1. **Preserve existing configs** - Don't destroy user's existing zsh/bash configurations
2. **Apply dotfiles configs** - Add paths, environment variables, aliases, etc.
3. **Environment-specific** - Use zshrc for macOS, bashrc for Codespaces
4. **Include Powerlevel10k** - Support p10k theme configuration for macOS
5. **Easy installation** - Single command installation for each environment
6. **Transparency** - User should know what was auto-generated vs their configs
7. **Public repository** - Repository will be made public, must not contain secrets

---

## Decision

Implement a **surgical installation approach** with environment-specific shell configurations:

### Core Strategy

**SURGICAL approach (shell configs ONLY):**
- **macOS**: Copy `.zshrc.dotfiles` to `~/.zshrc.dotfiles`, append `source ~/.zshrc.dotfiles` to user's `.zshrc`
- **Codespaces**: Copy `.bashrc.dotfiles` to `~/.bashrc.dotfiles`, append `source ~/.bashrc.dotfiles` to user's `.bashrc`
- Backup user's existing shell config with timestamp before modifying
- Preserves 100% of user's existing shell configuration

**FULL REPLACEMENT (all other files):**
- **Aliases**: Replace `~/.aliases` with timestamped backup
- **Powerlevel10k** (macOS): Replace `~/.p10k.zsh` with timestamped backup
- **Git config**: Replace `~/.gitconfig` with timestamped backup
- **Claude Code settings**: Replace `~/.claude/settings.json` with timestamped backup
- **ccstatusline settings**: Replace `~/.config/ccstatusline/settings.json` with timestamped backup

**Both environments:**
- Install Homebrew (macOS only), Powerlevel10k (macOS only), Node.js, Claude Code CLI, Happy Coder
- Repository contains no secrets or API keys
- Use GitHub no-reply email for privacy

**Key Principle:** Shell configs get surgical one-line append. Everything else gets full replacement with backups.

---

## File Structure

### User's Home Directory After Installation

**macOS:**
```
~/
├── .zshrc                         # User's original file + source line appended
├── .zshrc.backup.YYYY-MM-DD       # Timestamped backup of user's .zshrc
├── .zshrc.dotfiles                # Dotfiles shell config (copied from repo)
├── .aliases                       # REPLACED from dotfiles (backup created)
├── .aliases.backup.YYYY-MM-DD     # Timestamped backup
├── .p10k.zsh                      # REPLACED from dotfiles (backup created)
├── .p10k.zsh.backup.YYYY-MM-DD    # Timestamped backup
├── .gitconfig                     # REPLACED from dotfiles (backup created)
├── .gitconfig.backup.YYYY-MM-DD   # Timestamped backup
└── .claude/
    └── settings.json              # REPLACED from dotfiles (backup created)
```

**Content of user's `.zshrc` after installation:**
```zsh
# ... user's existing config 100% preserved here ...

# Dotfiles configuration (added by install-macos.sh)
source ~/.zshrc.dotfiles
```

**Codespaces:**
```
~/
├── .bashrc                        # User's original file + source line appended
├── .bashrc.backup.YYYY-MM-DD      # Timestamped backup of user's .bashrc
├── .bashrc.dotfiles               # Dotfiles shell config (copied from repo)
├── .aliases                       # REPLACED from dotfiles (backup created)
├── .aliases.backup.YYYY-MM-DD     # Timestamped backup
├── .gitconfig                     # REPLACED from dotfiles (backup created)
├── .gitconfig.backup.YYYY-MM-DD   # Timestamped backup
└── .claude/
    └── settings.json              # REPLACED from dotfiles (backup created)
```

**Content of user's `.bashrc` after installation:**
```bash
# ... user's existing config 100% preserved here ...

# Dotfiles configuration (added by install.sh)
source ~/.bashrc.dotfiles
```

### Dotfiles Repository Structure

```
dotfiles/
├── .gitignore                # Excludes secrets and backups
├── install.sh                # Installation script for Codespaces
├── install-macos.sh          # Installation script for macOS
├── README.md                 # Repository documentation
├── .docs/                    # Documentation
│   ├── 001-surgical-shell-installation.md
│   └── CLAUDE_NOTIFICATIONS_SETUP.md
├── shared/                   # Shared configuration files
│   ├── .gitconfig            # Git configuration (both environments)
│   ├── .claude-settings.json # Claude Code configuration
│   └── ccstatusline.settings.json # Claude Code status line
├── local-macos/              # macOS-specific configurations
│   ├── .zshrc                # macOS zsh configuration
│   ├── .p10k.zsh             # Powerlevel10k theme configuration
│   └── .aliases              # macOS aliases
└── codespaces/               # Codespaces-specific configurations
    ├── .bashrc               # Codespaces bash configuration
    └── .aliases              # Codespaces aliases
```

---

## Technical Implementation

### Installation Flow

**macOS (install-macos.sh):**
1. Verify macOS operating system
2. Install Homebrew if not present (supports both Intel and Apple Silicon)
3. Install Powerlevel10k theme via Homebrew
4. Install Node.js via Homebrew if needed

**SURGICAL (shell config):**
5. Copy `local-macos/.zshrc.dotfiles` → `~/.zshrc.dotfiles`
6. Backup user's `.zshrc` → `.zshrc.backup.YYYY-MM-DD`
7. Append `source ~/.zshrc.dotfiles` to user's `.zshrc`

**FULL REPLACEMENT (other files):**
8. Replace `~/.aliases` (backup to `.aliases.backup.YYYY-MM-DD`)
9. Replace `~/.p10k.zsh` (backup to `.p10k.zsh.backup.YYYY-MM-DD`)
10. Replace `~/.gitconfig` (backup to `.gitconfig.backup.YYYY-MM-DD`)

**INSTALL TOOLS:**
11. Install Claude Code CLI via npm
12. Install Happy Coder via npm
13. Replace `~/.claude/settings.json` (with backup)
14. Replace `~/.config/ccstatusline/settings.json` (with backup)

**Codespaces (install.sh):**
1. Detect Codespaces environment
2. Install Node.js if needed

**SURGICAL (shell config):**
3. Copy `codespaces/.bashrc.dotfiles` → `~/.bashrc.dotfiles`
4. Backup user's `.bashrc` → `.bashrc.backup.YYYY-MM-DD`
5. Append `source ~/.bashrc.dotfiles` to user's `.bashrc`

**FULL REPLACEMENT (other files):**
6. Replace `~/.aliases` (backup to `.aliases.backup.YYYY-MM-DD`)
7. Replace `~/.gitconfig` (backup to `.gitconfig.backup.YYYY-MM-DD`)

**INSTALL TOOLS:**
8. Install Claude Code CLI via npm
9. Install Happy Coder via npm
10. Replace `~/.claude/settings.json` (with backup)
11. Replace `~/.config/ccstatusline/settings.json` (with backup)

### Key Features

- **Idempotent**: Can run multiple times safely (checks if source line already exists)
- **Surgical for shell configs**: Only appends one line to `.bashrc`/`.zshrc`
- **Full replacement for other files**: Replaces aliases, git config, etc. with timestamped backups
- **Preserves user customizations**: Shell configs 100% preserved
- **Shell-specific**: Uses zsh for macOS, bash for Codespaces
- **Automated**: Installs all dependencies automatically
- **Theme support**: Includes Powerlevel10k configuration for macOS

---

## Shell Configuration Details

### macOS (zsh) Configuration

The `.zshrc` file for macOS includes:

1. **Powerlevel10k Setup**
   - Instant prompt for fast startup
   - Custom theme configuration via `.p10k.zsh`
   - Lean prompt style with compact layout

2. **Path Management**
   - Homebrew paths (`/opt/homebrew/bin` for Apple Silicon)
   - Local bin directory (`~/.local/bin`)

3. **Environment Variables**
   - LANG (locale settings)
   - HAPPY_SERVER_URL (for push notifications)

4. **Custom Aliases**
   - Sourced from separate `.aliases` file

5. **Secrets Management**
   - Automatically sources `~/.secrets.zsh` if it exists
   - For API keys, tokens, and other credentials
   - File is already in `.gitignore`

**Security Note:** The dotfiles version will NOT include API keys or secrets. Users must manage these separately in `~/.secrets.zsh`.

### Codespaces (bash) Configuration

The `.bashrc` file for Codespaces includes:

1. **Path Management**
   - Standard PATH additions for Codespaces environment
   - Node.js and npm paths

2. **Environment Variables**
   - HAPPY_SERVER_URL (for push notifications)
   - Codespace-specific variables

3. **Aliases**
   - Sourced from separate `.aliases` file
   - Codespace-optimized commands

**Security Note:** For Codespaces, use GitHub's built-in [secrets management](https://docs.github.com/en/codespaces/managing-your-codespaces/managing-secrets-for-your-codespaces) instead of local files.

---

## PATH Configuration

### How PATH Works with Existing User Configs

**Key Concept:** When you add a `source` command at the end of your existing shell config, both files run in order. The **last** `export PATH=` to prepend a path wins (appears first in search order).

### Example (applies to both macOS and Codespaces)

**Scenario:** User already has custom PATH in their shell config:

```bash
# User's existing ~/.zshrc or ~/.bashrc
export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="$HOME/my-tools:$PATH"

# Installation adds this line at the end:
source ~/.zshrc.dotfiles  # or ~/.bashrc.dotfiles
```

**Our dotfiles config adds:**

```bash
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
```

**What happens when shell loads:**

1. User's config runs first → prepends `$HOME/.pyenv/bin`, then `$HOME/my-tools`
2. Dotfiles config runs second → prepends `/opt/homebrew/bin`, then `$HOME/.local/bin`

**Final PATH search order:**
```
$HOME/.local/bin           ← Dotfiles (added last, searched first)
/opt/homebrew/bin          ← Dotfiles
$HOME/my-tools             ← User's config (added last in user's section)
$HOME/.pyenv/bin           ← User's config (added first in user's section)
/usr/bin:/bin:/usr/sbin... ← System defaults
```

**Winner:** Dotfiles paths searched first because they were added last.

### Summary

- Shell reads PATH from left to right
- First match wins when searching for commands
- `export PATH="new:$PATH"` prepends to existing PATH
- Last prepend wins (appears first in final PATH)
- Dotfiles config sources last → Dotfiles paths have highest priority

---

## Migration Guide

### For Existing macOS Users

If you're migrating from the old bash-based configuration:

1. **Run the macOS installer** (it will append to your existing `.zshrc`):
   ```bash
   ./install-macos.sh
   ```

2. **Check what was added:**
   ```bash
   tail -5 ~/.zshrc
   # Should show: source ~/dotfiles/local-macos/.zshrc
   ```

3. **Verify the installation:**
   ```bash
   # Check that zsh is your shell
   echo $SHELL
   # Should output: /bin/zsh

   # Check that Powerlevel10k is loaded
   p10k configure
   ```

4. **Your existing configs are preserved:**
   - All your customizations remain in place
   - Dotfiles config loads after your config
   - Review backup file if needed: `.zshrc.backup.YYYY-MM-DD`

### For Codespaces Users

No changes needed if you're already using bash. Just run:

```bash
./install.sh
```

---

## Security Considerations

### API Keys and Secrets

**DO NOT include in repository:**
- API keys
- Authentication tokens
- Personal access tokens
- SSH private keys
- Any credentials or secrets

**Recommended approach for macOS:**
1. Create a separate file for secrets: `~/.secrets.zsh`
2. This file is already in `.gitignore`
3. Our `.zshrc.dotfiles` automatically sources it if it exists

**For Codespaces:**
Use GitHub's built-in [Codespaces secrets management](https://docs.github.com/en/codespaces/managing-your-codespaces/managing-secrets-for-your-codespaces) to securely store API keys and credentials.

### Privacy

- Use GitHub no-reply email in `.gitconfig`
- Review all files before committing
- Use `.gitignore` to exclude sensitive files

---

## Notes

### Powerlevel10k Configuration

The included `.p10k.zsh` configuration uses:
- Lean prompt style
- ASCII characters with Nerd Font icons
- Compact layout
- 1-line prompt
- Transient prompt for clean history
- Instant prompt disabled for compatibility

To reconfigure:
```bash
p10k configure
```

### Testing

Before making the repository public:
1. Review all files for secrets
2. Test installation on fresh macOS system
3. Test installation on fresh Codespace
4. Verify all paths and environment variables
5. Confirm Claude Code and Happy CLI integration works

---

## References

- [Powerlevel10k Documentation](https://github.com/romkatv/powerlevel10k)
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Bash Startup Files](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html)
- [Claude Code Documentation](https://docs.claude.com/claude-code)
