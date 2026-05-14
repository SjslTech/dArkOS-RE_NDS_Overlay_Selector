#!/bin/bash

# --- Run as root ---
if [ "$(id -u)" -ne 0 ]; then
    exec sudo -- "$0" "$@"
fi

# --- Script Info ---
SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
SCRIPT_NAME=$(basename "$SCRIPT_PATH")

CURR_TTY="/dev/tty1"

# --- Paths ---
SOURCE_BASE="$SCRIPT_DIR/NDS_BG"
DEST_DIR="/opt/advanceddrastic/resources/bg/640x480/9"

# --- Terminal Setup ---
exec > $CURR_TTY 2>&1
printf "\033c" > "$CURR_TTY"

export TERM=linux

# --- Controller Setup ---
pkill -9 -f gptokeyb || true

if [ -f "/opt/inttools/gptokeyb" ]; then
    chmod 666 /dev/uinput 2>/dev/null || true

    export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"

    /opt/inttools/gptokeyb -1 "$SCRIPT_NAME" \
        -c "/opt/inttools/keys.gptk" >/dev/null 2>&1 &
fi

# --- Cleanup ---
ExitScript() {
    pkill -f "gptokeyb -1 $SCRIPT_NAME" || true
    printf "\033c\e[?25h" > "$CURR_TTY"
    exit 0
}

trap ExitScript EXIT SIGINT SIGTERM

printf "\e[?25l" > "$CURR_TTY"

# --- Apply Background ---
apply_background() {

    BG_NUM="$1"
    SRC_DIR="$SOURCE_BASE/$BG_NUM"

    # Verify source exists
    if [ ! -d "$SRC_DIR" ]; then
        dialog --msgbox "Background folder not found:\n$SRC_DIR" 8 50
        return
    fi

    # Copy files
    cp -R "$SRC_DIR"/* "$DEST_DIR"/

    sync

    dialog --msgbox "Backgrounds updated successfully!" 6 40
}

# --- Main Menu ---
while true; do

    CHOICE=$(dialog \
        --backtitle "AdvancedDrastic Background Selector" \
        --title " SELECT BACKGROUND " \
        --menu "Choose a background:" 18 50 10 \
        1 "Background 1" \
        2 "Background 2" \
        3 "Background 3" \
        4 "Background 4" \
        5 "Background 5" \
        6 "Background 6" \
        7 "Background 7" \
        8 "Background 8" \
        9 "Background 9" \
        0 "Exit" \
        --output-fd 1)

    case "$CHOICE" in
        1|2|3|4|5|6|7|8|9)
            apply_background "$CHOICE"
            ;;
        0|*)
            ExitScript
            ;;
    esac

done
