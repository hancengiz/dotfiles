# ADR 001: Surgical .bashrc Installation for macOS Dotfiles

**Status:** Proposed
**Date:** 2025-10-14
**Decision Makers:** Cengiz Han
**Technical Story:** Support local macOS installation without destroying user's existing configurations

---

## Context

The dotfiles repository was originally designed for GitHub Codespaces with a destructive installation approach - symlinks replace existing dotfiles entirely. When adapting for local macOS use, we need to preserve users' existing configurations, especially in `.bashrc` which often contains critical machine-specific settings.

### Problem

Current approach would overwrite existing `.bashrc` which could cause:
- Loss of environment variables for tools installed directly on the system
- Loss of shell integrations and terminal customizations
- Loss of custom PATH configurations for locally installed tools
- Loss of any other user customizations accumulated over time

### User Requirements

1. **Preserve existing .bashrc** - Don't destroy what the user already has
2. **Apply dotfiles configs** - Add Homebrew paths, HAPPY_SERVER_URL, aliases, etc.
3. **Detect conflicts** - Warn if there are overlapping configurations
4. **Easy resolution** - Provide tools to resolve conflicts interactively
5. **Replaceable for others** - `.aliases` and `.gitconfig` can be replaced with backups
6. **Transparency** - User should know what was auto-generated vs their configs
7. **Public repository** - Repository will be made public, must not contain secrets

---

## Decision

Implement a **surgical installation approach** for `.bashrc` while keeping replacement strategy for `.aliases` and `.gitconfig`:

### Core Strategy

**For macOS (.bashrc, .aliases, .gitconfig):**
- Create `.backup` backups of existing files
- Replace with symlinks to macOS-specific versions
- User can restore from backups if needed

**For Codespaces (.bashrc, .aliases, .gitconfig):**
- Simple symlink replacement (no existing configs to preserve)
- Suitable for fresh Codespace environments

**For both environments:**
- Install Claude Code CLI
- Install Happy Coder CLI for push notifications
- Configure Claude Code settings and hooks
- Repository contains no secrets or API keys

---

## File Structure

### User's Home Directory After Installation

```
~/
├── .bashrc                   # Symlink to dotfiles (macOS) or dotfiles version (Codespaces)
├── .bashrc.backup            # Backup of original (if existed)
├── .aliases                  # Symlink to dotfiles
├── .aliases.backup           # Backup of original (if existed)
├── .gitconfig                # Symlink to dotfiles
├── .gitconfig.backup         # Backup of original (if existed)
└── .claude/
    └── settings.json         # Copied from dotfiles
```

### Dotfiles Repository Structure

```
dotfiles/
├── .bashrc                   # For Codespaces
├── .aliases                  # For Codespaces
├── .gitconfig                # Shared (uses GitHub no-reply email for privacy)
├── .gitignore                # Excludes secrets and backups
├── .claude-settings.json     # Claude Code configuration with Happy CLI hooks
├── ccstatusline.settings.json # Claude Code status line configuration
├── install.sh                # Installation script for Codespaces
├── install-macos.sh          # Installation script for macOS
├── local-macos/
│   ├── .bashrc.macos         # macOS-specific bash configuration
│   └── .aliases.macos        # macOS-specific aliases
├── docs/
│   ├── 001-surgical-bashrc-installation.md
│   └── CLAUDE_NOTIFICATIONS_SETUP.md
└── README.md
```

---

## Technical Implementation

### Installation Flow

**macOS (install-macos.sh):**
1. Verify macOS operating system
2. Install Homebrew if not present (supports both Intel and Apple Silicon)
3. Create `.backup` backups of existing dotfiles
4. Create symlinks to macOS-specific versions
5. Install Node.js via Homebrew if needed
6. Install Claude Code CLI via npm
7. Install Happy Coder CLI via npm
8. Copy Claude Code settings and ccstatusline configuration

**Codespaces (install.sh):**
1. Detect Codespaces environment
2. Create symlinks to Codespaces versions
3. Install Node.js if needed
4. Install Claude Code CLI via npm
5. Install Happy Coder CLI via npm
6. Copy Claude Code settings and ccstatusline configuration

### Key Features

- **Idempotent**: Can run multiple times safely
- **Non-destructive**: Creates backups before modifying
- **Cross-platform**: Separate configs for macOS and Codespaces
- **Automated**: Installs all dependencies automatically

---

## Consequences

### Benefits

1. **Automated Setup**
   - Single command installation for both environments
   - Handles all dependencies automatically
   - No manual configuration required

2. **Reversible**
   - `.backup` files allow easy rollback
   - Can restore original configuration if needed

3. **Environment-Specific**
   - Separate configs for macOS and Codespaces
   - macOS includes Homebrew path management
   - Codespaces optimized for cloud environment

4. **Secure**
   - Uses GitHub no-reply email for privacy
   - No API keys or secrets in repository
   - .gitignore prevents accidental secret commits

### Trade-offs

1. **Replaces Existing Configs**
   - Original dotfiles are backed up but replaced
   - Users with complex custom configs may need to manually merge
   - Simple backup strategy (not timestamped, single backup per run)

---

## Notes

### PATH Configuration

When `.bashrc` sources `.bashrc.dotfiles`, both files use the same pattern `export PATH="newpath:$PATH"` but execute at different times. Here's how PATH builds up:

**Step-by-step execution:**

```bash
# 1. INITIAL STATE (system default)
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# 2. USER'S .bashrc runs first
export PATH="$HOME/.local/bin:$PATH"
# Takes current PATH and prepends $HOME/.local/bin
# PATH is now: $HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# 3. USER'S .bashrc then sources dotfiles
source ~/.bashrc.dotfiles

# 4. DOTFILES .bashrc.dotfiles runs second
export PATH="/opt/homebrew/bin:$PATH"
# Takes current PATH (which already includes $HOME/.local/bin!) and prepends /opt/homebrew/bin
# PATH is now: /opt/homebrew/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
```

**Final result:**

```text
PATH=/opt/homebrew/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin
     └─────┬──────┘    └──────┬───────┘    └─────────┬─────────┘
        DOTFILES            USER                  SYSTEM
       (added last,      (added first,         (original)
       appears first)    appears second)
```

**Why dotfiles paths come first:**

Both files use the same pattern: `export PATH="X:$PATH"`

But execution order determines final position:
1. User's .bashrc executes → adds to PATH
2. Then user's .bashrc sources .bashrc.dotfiles → adds to PATH again
3. The second addition prepends to what's already there
4. Result: dotfiles paths appear first, even though they were added last

**Search precedence:**
- Shell searches left-to-right
- `/opt/homebrew/bin` checked first (dotfiles override everything)
- `$HOME/.local/bin` checked second (user overrides system)
- System paths checked last
