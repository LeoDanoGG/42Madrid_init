#!/bin/bash

# ==============================================================================
# 42init - Interactive project scaffolder for 42 School
#
# 42init        Interactive wizard (create a project or sync an existing one)
# 42init sync   Shortcut: refresh SRCS and the README file list right here
# ==============================================================================

BLUE="\033[34m"; GREEN="\033[32m"; YELLOW="\033[33m"
RED="\033[31m"; CYAN="\033[36m"; RESET="\033[0m"

info() { echo -e "${BLUE}[+] $1${RESET}"; }
ok()   { echo -e "${GREEN}✔ $1${RESET}"; }
warn() { echo -e "${YELLOW}[!] $1${RESET}"; }
err()  { echo -e "${RED}Error: $1${RESET}"; }

# ==============================================================================
# HELPERS
# ==============================================================================

# Returns 1 (and warns) if the file already exists, so we never overwrite work.
can_write() {
    if [ -e "$1" ]; then
        warn "$1 already exists, skipping."
        return 1
    fi
    return 0
}

# Asks for option 1 or 2. Result in $ANSWER. Default: 1.
ask_option() {
    local reply
    while true; do
        read -r -p "$1" reply
        reply="${reply:-1}"
        case "$reply" in
            1|2) ANSWER="$reply"; return ;;
        esac
        err "Please enter 1 or 2."
    done
}

# Asks a yes/no question. Result in $ANSWER ("y" or "n"). $2 = default.
ask_yn() {
    local reply
    while true; do
        read -r -p "$1" reply
        reply="${reply:-$2}"
        case "$reply" in
            [Yy]*) ANSWER="y"; return ;;
            [Nn]*) ANSWER="n"; return ;;
        esac
        err "Please answer y or n."
    done
}

# ==============================================================================
# SYNC: update SRCS in Makefile and file list in README.md
# ==============================================================================
sync_sources() {
    local raw block

    info "Scanning directory for .c files..."
    raw=$(find . -maxdepth 1 -name '*.c' | sed 's|^\./||' | sort | xargs -n 5)

    if [ -z "$raw" ]; then
        warn "No .c files found in the current directory."
        block="SRCS        ="
    else
        # First line: 'SRCS        = ...', the rest aligned; last line has no '\'
        block=$(printf '%s\n' "$raw" | awk '
            { lines[NR] = (NR == 1 ? "SRCS        = " : "              ") $0 }
            END { for (i = 1; i <= NR; i++) print lines[i] (i < NR ? " \\" : "") }
        ')
    fi

    # --- Makefile ---
    if [ ! -f Makefile ]; then
        warn "No Makefile found. Skipping Makefile update."
    elif ! grep -q '^# SRCS_START$' Makefile || ! grep -q '^# SRCS_END$' Makefile; then
        warn "Makefile has no '# SRCS_START' / '# SRCS_END' markers. Skipping."
    else
        BLOCK="$block" awk '
            /^# SRCS_END$/   { skip = 0 }
            !skip            { print }
            /^# SRCS_START$/ { skip = 1; print ENVIRON["BLOCK"] }
        ' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
        ok "Makefile updated (5 files per line)."
    fi

    # --- README.md ---
    if [ ! -f README.md ]; then
        warn "No README.md found. Skipping README update."
    elif ! grep -q '^<!-- FILES_START -->$' README.md || ! grep -q '^<!-- FILES_END -->$' README.md; then
        warn "README.md has no <!-- FILES_START --> / <!-- FILES_END --> markers. Skipping."
    else
        LIST="$raw" awk '
            /^<!-- FILES_END -->$/   { skip = 0 }
            !skip                    { print }
            /^<!-- FILES_START -->$/ {
                skip = 1
                print "```c"
                if (ENVIRON["LIST"] != "") print ENVIRON["LIST"]
                print "```"
            }
        ' README.md > README.tmp && mv README.tmp README.md
        ok "README.md updated."
    fi
}

# Shortcut: 42init sync
if [ "$1" = "sync" ]; then
    sync_sources
    exit 0
fi

# ==============================================================================
# INTERACTIVE WIZARD
# ==============================================================================
clear
echo -e "${CYAN}==================================================${RESET}"
echo -e "${CYAN}             🚀 42 PROJECT INITIALIZER            ${RESET}"
echo -e "${CYAN}==================================================${RESET}"
echo ""

# Question 0: mode
echo -e "${YELLOW}Select an action:${RESET}"
echo "  1) Create / Scaffold a new project"
echo "  2) Sync / Update .c files in current directory (Makefile & README)"
ask_option "Option [1/2] (default 1): "

if [ "$ANSWER" = "2" ]; then
    sync_sources
    exit 0
fi

# Question 1: project name
echo ""
while true; do
    read -r -p "📁 Enter project/directory name: " DIR_NAME
    if [[ "$DIR_NAME" =~ ^[A-Za-z0-9._-]+$ && "$DIR_NAME" != "." && "$DIR_NAME" != ".." ]]; then
        break
    fi
    err "Use only letters, digits, '.', '_' or '-' (no spaces or slashes)."
done

# Question 2: local vs git clone
echo ""
echo -e "${YELLOW}Repository Setup:${RESET}"
echo "  1) Local directory"
echo "  2) Git clone (Vogsphere / GitHub)"
ask_option "Option [1/2] (default 1): "
REPO_TYPE="$ANSWER"

GIT_URL=""
if [ "$REPO_TYPE" = "2" ]; then
    while [ -z "$GIT_URL" ]; do
        read -r -p "🔗 Enter Git URL: " GIT_URL
    done
fi

# Question 3: authors (default: the current login)
DEFAULT_USER="${USER:-$(whoami)}"
echo ""
read -r -p "👤 Enter author login(s) (default: $DEFAULT_USER): " USERS
USERS="${USERS:-$DEFAULT_USER}"

# Question 4: language
echo ""
echo -e "${YELLOW}Select Project Language:${RESET}"
echo "  1) C (Common Core / Piscine)"
echo "  2) Python (Common Core)"
ask_option "Option [1/2] (default 1): "
LANG_CHOICE="$ANSWER"

NEED_MAKEFILE="n"
USE_LIB="n"
if [ "$LANG_CHOICE" = "1" ]; then
    echo ""
    ask_yn "🛠️  Generate a Makefile? [Y/n]: " "y"
    NEED_MAKEFILE="$ANSWER"

    if [ "$NEED_MAKEFILE" = "y" ]; then
        ask_yn "📚 Link against your own libft (./libft)? [y/N]: " "n"
        USE_LIB="$ANSWER"
    fi
fi

# Question 5: README
echo ""
ask_yn "📝 Generate README.md? [Y/n]: " "y"
NEED_README="$ANSWER"

# ==============================================================================
# EXECUTION: scaffolding
# ==============================================================================
echo ""
info "Scaffolding project '$DIR_NAME'..."

if [ "$REPO_TYPE" = "2" ]; then
    git clone "$GIT_URL" "$DIR_NAME" || { err "Failed to clone repository."; exit 1; }
else
    if [ -d "$DIR_NAME" ]; then
        warn "Directory '$DIR_NAME' already exists: existing files will be kept."
    fi
    mkdir -p "$DIR_NAME"
fi

cd "$DIR_NAME" || exit 1

# Valid C identifier: uppercase, anything else -> '_', no leading digit
HEADER_GUARD="$(echo "$DIR_NAME" | tr '[:lower:]' '[:upper:]' | tr -c 'A-Z0-9\n' '_')_H"
[[ "$HEADER_GUARD" =~ ^[0-9] ]] && HEADER_GUARD="_$HEADER_GUARD"

# ------------------------------------------------------------------------------
# C project (.h & Makefile)
# ------------------------------------------------------------------------------
if [ "$LANG_CHOICE" = "1" ]; then

    if can_write "$DIR_NAME.h"; then
        info "Creating $DIR_NAME.h..."
        cat << EOF > "$DIR_NAME.h"
#ifndef $HEADER_GUARD
# define $HEADER_GUARD

# include <unistd.h>
# include <stdlib.h>

/* Code */

#endif
EOF
    fi

    if [ "$NEED_MAKEFILE" = "y" ] && can_write Makefile; then
        info "Creating Makefile..."

        if [ "$USE_LIB" = "y" ]; then
            cat << EOF > Makefile
NAME        = $DIR_NAME

# SRCS_START
SRCS        =
# SRCS_END

OBJS        = \$(SRCS:.c=.o)

HEADER      = $DIR_NAME.h
LIBFT_DIR   = ./libft
LIBFT       = \$(LIBFT_DIR)/libft.a
INCLUDES    = -I. -I\$(LIBFT_DIR)
LIBS        = -L\$(LIBFT_DIR) -lft

CC          = cc
CFLAGS      = -Wall -Wextra -Werror
RM          = rm -f

all: \$(NAME)

\$(NAME): \$(LIBFT) \$(OBJS)
	\$(CC) \$(CFLAGS) \$(OBJS) \$(LIBS) -o \$(NAME)

\$(LIBFT): FORCE
	@\$(MAKE) -C \$(LIBFT_DIR)

%.o: %.c \$(HEADER)
	\$(CC) \$(CFLAGS) \$(INCLUDES) -c \$< -o \$@

clean:
	\$(RM) \$(OBJS)
	@if [ -d "\$(LIBFT_DIR)" ]; then \$(MAKE) -C \$(LIBFT_DIR) clean; fi

fclean: clean
	\$(RM) \$(NAME)
	@if [ -d "\$(LIBFT_DIR)" ]; then \$(MAKE) -C \$(LIBFT_DIR) fclean; fi

re: fclean all

FORCE:

.PHONY: all clean fclean re FORCE
EOF
        else
            cat << EOF > Makefile
NAME        = $DIR_NAME

# SRCS_START
SRCS        =
# SRCS_END

OBJS        = \$(SRCS:.c=.o)
HEADER      = $DIR_NAME.h

CC          = cc
CFLAGS      = -Wall -Wextra -Werror -I.
RM          = rm -f

all: \$(NAME)

\$(NAME): \$(OBJS)
	\$(CC) \$(CFLAGS) \$(OBJS) -o \$(NAME)

%.o: %.c \$(HEADER)
	\$(CC) \$(CFLAGS) -c \$< -o \$@

clean:
	\$(RM) \$(OBJS)

fclean: clean
	\$(RM) \$(NAME)

re: fclean all

.PHONY: all clean fclean re
EOF
        fi
    fi

# ------------------------------------------------------------------------------
# Python project
# ------------------------------------------------------------------------------
else
    info "Setting up Python project structure..."

    if can_write main.py; then
        cat << EOF > main.py
#!/usr/bin/env python3
"""
Project: $DIR_NAME
Author(s): $USERS
"""


def main():
    print("Hello from $DIR_NAME!")


if __name__ == "__main__":
    main()
EOF
        chmod +x main.py
    fi
    [ -e requirements.txt ] || touch requirements.txt
fi

# ------------------------------------------------------------------------------
# README.md
# ------------------------------------------------------------------------------
if [ "$NEED_README" = "y" ] && can_write README.md; then
    info "Creating README.md..."

    # The file list (and its markers) only makes sense for C projects
    FILES_SECTION=""
    if [ "$LANG_CHOICE" = "1" ]; then
        FILES_SECTION="### Project Files

<!-- FILES_START -->
<!-- FILES_END -->
"
    fi

    cat << EOF > README.md
*This project has been created as part of the 42 curriculum by $USERS.*

# $DIR_NAME

## Description

<!-- Goal of the project, short overview and allowed external functions. -->

$FILES_SECTION
## Algorithm / Architecture: explanation and justification

<!--
- Data structures or classes used and why.
- Step-by-step flow, ideally with a worked example.
- Memory management / performance.
- Trade-offs and limitations.
-->

## Instructions

### Usage

<!-- How to run it, with a short example. -->

### Testing

<!-- Edge cases tested and tools used. -->

## Resources

- [Resource name](https://example.com) - what it was used for.

### Use of AI

<!-- Which AI tools were used, for which tasks and for which parts of the project. -->
EOF
fi

# Pick up any .c files that were already there (e.g. a cloned repository)
if [ "$LANG_CHOICE" = "1" ] && compgen -G "*.c" > /dev/null; then
    sync_sources
fi

# ------------------------------------------------------------------------------

echo ""
echo -e "${GREEN}✨ Workspace for '$DIR_NAME' successfully created for [$USERS]!${RESET}"
