#!/bin/bash
# AICheck UI Color Definitions
# This module defines all color codes used throughout AICheck

# Basic Colors
export GREEN="\033[0;32m"
export YELLOW="\033[0;33m"
export RED="\033[0;31m"
export CYAN="\033[0;36m"
export BLUE="\033[0;34m"
export PURPLE="\033[0;35m"
export NC="\033[0m" # No Color

# Special Colors
export NEON_BLURPLE="\033[38;5;99m"      # Neon blurple highlight color
export BRIGHT_BLURPLE="\033[38;5;135m"   # Bright blurple for text
export ORANGE="\033[38;5;208m"           # Orange for warnings
export GRAY="\033[0;90m"                 # Gray for subtle text

# Text Formatting
export BOLD="\033[1m"
export DIM="\033[2m"
export ITALIC="\033[3m"
export UNDERLINE="\033[4m"

# Emoji indicators (can be disabled with NO_EMOJI=1)
if [ "${NO_EMOJI:-0}" = "1" ]; then
    export CHECK_MARK="[OK]"
    export CROSS_MARK="[FAIL]"
    export WARNING_SIGN="[WARN]"
    export INFO_SIGN="[INFO]"
    export ROCKET="[START]"
    export SPARKLES="[NEW]"
else
    export CHECK_MARK="✓"
    export CROSS_MARK="✗"
    export WARNING_SIGN="⚠️"
    export INFO_SIGN="ℹ"
    export ROCKET="🚀"
    export SPARKLES="✨"
fi