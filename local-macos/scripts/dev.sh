#!/bin/bash
# Opens iTerm2 with a vertical split: lazygit on the left, claude code on the right

osascript <<'EOF'
tell application "iTerm2"
    activate

    tell current session of current tab of current window
        -- Left pane: lazygit
        write text "lazygit"

        -- Split vertically to create right pane
        set rightPane to (split vertically with default profile)
    end tell

    tell rightPane
        -- Right pane: claude code
        write text "cc"
    end tell
end tell
EOF
