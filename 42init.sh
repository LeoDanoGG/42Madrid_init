#!/bin/bash

# ==============================================================================
# UPDATER FUNCTION (Pure Shell Execution & Safe Block Formatting)
# ==============================================================================

update_existing_project() {
    echo -e "\033[34m[+] Scanning directory for .c files...\033[0m"

    # Step 1: Discover .c files, strip ./, sort and group 5 per line
    RAW_FILES=$(find . -maxdepth 1 -name '*.c' | sed 's|^\./||' | sort | xargs -n 5)

    if [ -z "$RAW_FILES" ]; then
        echo -e "\033[31mError: No .c files found in the current directory.\033[0m"
        exit 1
    fi

    # Step 2: Build clean Makefile SRCS block (1st line: 'SRCS        = ...', rest: '              ...')
    MAKEFILE_BLOCK=""
    IS_FIRST=1
    LINE_COUNT=$(echo "$RAW_FILES" | wc -l | tr -d ' ')
    CURRENT_LINE=0

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        CURRENT_LINE=$((CURRENT_LINE + 1))
        
        if [ $IS_FIRST -eq 1 ]; then
            PREFIX="SRCS        = "
            IS_FIRST=0
        else
            PREFIX="              "
        fi

        if [ $CURRENT_LINE -lt $LINE_COUNT ]; then
            MAKEFILE_BLOCK="${MAKEFILE_BLOCK}${PREFIX}${line} \\"$'\n'
        else
            MAKEFILE_BLOCK="${MAKEFILE_BLOCK}${PREFIX}${line}"
        fi
    done <<< "$RAW_FILES"

    # Step 3: Update Makefile cleanly between # SRCS_START and # SRCS_END
    if [ -f Makefile ]; then
        export MAKEFILE_BLOCK
        awk '
            /# SRCS_END/ {skip=0} 
            !skip {print} 
            /# SRCS_START/ {skip=1; print ENVIRON["MAKEFILE_BLOCK"]}
        ' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
        echo -e "\033[32m✔ Makefile updated successfully with .c files (grouped by 5).\033[0m"
    else
        echo -e "\033[33m[!] No Makefile found in this directory. Skipping Makefile update.\033[0m"
    fi

    # Step 4: Update README.md cleanly between <!-- FILES_START --> and <!-- FILES_END -->
    if [ -f README.md ]; then
        export RAW_FILES
        awk '
            /<!-- FILES_END -->/ {skip=0} 
            !skip {print} 
            /<!-- FILES_START -->/ {skip=1; print "\n"; print "```c"; print ENVIRON["RAW_FILES"]; print "```"}
        ' README.md > README.tmp && mv README.tmp README.md
        echo -e "\033[32m✔ README.md updated successfully.\033[0m"
    fi

    echo -e "\033[32m✨ Makefile & README.md successfully synchronized!\033[0m"
}

# ==============================================================================
# INTERACTIVE MODE & PROJECT MODES
# ==============================================================================

clear
echo -e "\033[36m==================================================\033[0m"
echo -e "\033[36m             🚀 42 PROJECT INITIALIZER            \033[0m"
echo -e "\033[36m==================================================\033[0m"
echo ""

# Question 0: Mode selection
echo -e "\033[33mSelect an action:\033[0m"
echo "  1) Create / Scaffold a new project"
echo "  2) Sync / Update .c files in current directory (Makefile & README)"
read -p "Option [1/2] (default 1): " ACTION_MODE
ACTION_MODE="${ACTION_MODE:-1}"

if [ "$ACTION_MODE" -eq 2 ]; then
    update_existing_project
    exit 0
fi

echo ""
# Question 1: Project Name
read -p "📁 Enter project/directory name: " DIR_NAME
while [ -z "$DIR_NAME" ]; do
    echo -e "\033[31mError: Project name cannot be empty.\033[0m"
    read -p "📁 Enter project/directory name: " DIR_NAME
done

# Question 2: Setup type (Local vs Git Clone)
echo ""
echo -e "\033[33mRepository Setup:\033[0m"
echo "  1) Local directory"
echo "  2) Git clone (Vogsphere / GitHub)"
read -p "Option [1/2] (default 1): " REPO_TYPE
REPO_TYPE="${REPO_TYPE:-1}"

GIT_URL=""
if [ "$REPO_TYPE" -eq 2 ]; then
    read -p "🔗 Enter Git URL: " GIT_URL
fi

# Question 3: User/Authors
echo ""
read -p "👤 Enter author login(s) (default: Enter): " USERS
USERS="${USERS:-legomez}"

# Question 4: Language type (C vs Python)
echo ""
echo -e "\033[33mSelect Project Language:\033[0m"
echo "  1) C (Common Core / Piscine)"
echo "  2) Python (Common Core)"
read -p "Option [1/2] (default 1): " LANG_CHOICE
LANG_CHOICE="${LANG_CHOICE:-1}"

# C-Specific Questions
NEED_MAKEFILE="n"
USE_LIB="n"
if [ "$LANG_CHOICE" -eq 1 ]; then
    echo ""
    read -p "🛠️  Generate a Makefile? [Y/n]: " NEED_MAKEFILE
    NEED_MAKEFILE="${NEED_MAKEFILE:-y}"

    if [[ "$NEED_MAKEFILE" =~ ^[Yy]$ ]]; then
        read -p "📚 Will you use an external library (e.g., Libft / MLX)? [y/N]: " USE_LIB
        USE_LIB="${USE_LIB:-n}"
    fi
fi

# Question 5: README Generation
echo ""
read -p "📝 Generate README.md? [Y/n]: " NEED_README
NEED_README="${NEED_README:-y}"

# ==============================================================================
# EXECUTION: Scaffolding Workspace
# ==============================================================================

echo ""
echo -e "\033[34m[+] Scaffolding project '$DIR_NAME'...\033[0m"

# Clone or create directory
if [ "$REPO_TYPE" -eq 2 ] && [ -n "$GIT_URL" ]; then
    git clone "$GIT_URL" "$DIR_NAME"
    if [ $? -ne 0 ]; then
        echo -e "\033[31mError: Failed to clone repository.\033[0m"
        exit 1
    fi
else
    mkdir -p "$DIR_NAME"
fi

cd "$DIR_NAME" || exit 1

HEADER_GUARD="$(echo "$DIR_NAME" | tr '[:lower:]' '[:upper:]')_H"

# ------------------------------------------------------------------------------
# C Project Setup
# ------------------------------------------------------------------------------
if [ "$LANG_CHOICE" -eq 1 ]; then
    # Generate .h file
    echo -e "\033[34m[+] Creating $DIR_NAME.h...\033[0m"
    cat << EOF > "$DIR_NAME.h"
#ifndef $HEADER_GUARD
# define $HEADER_GUARD

# include <unistd.h>
# include <stdlib.h>

/* Code */

#endif
EOF

    # Generate Makefile if requested
    if [[ "$NEED_MAKEFILE" =~ ^[Yy]$ ]]; then
        echo -e "\033[34m[+] Creating Makefile...\033[0m"

        if [[ "$USE_LIB" =~ ^[Yy]$ ]]; then
            # Makefile WITH Library support (Libft)
            cat << EOF > Makefile
NAME        = $DIR_NAME

# SRCS_START
SRCS        = 
# SRCS_END

OBJS        = \$(SRCS:.c=.o)

# Headers & Include paths
INCLUDES    = -I. -I./libft

# Libraries & Linker flags
LIBFT_DIR   = ./libft
LIBFT       = \$(LIBFT_DIR)/libft.a
LIBS        = -L\$(LIBFT_DIR) -lft

CC          = cc
CFLAGS      = -Wall -Wextra -Werror
RM          = rm -f

all: \$(NAME)

\$(NAME): \$(LIBFT) \$(OBJS)
	\$(CC) \$(CFLAGS) \$(OBJS) \$(LIBS) -o \$(NAME)

\$(LIBFT):
	@if [ -d "\$(LIBFT_DIR)" ]; then \$(MAKE) -C \$(LIBFT_DIR); fi

%.o: %.c
	\$(CC) \$(CFLAGS) \$(INCLUDES) -c $< -o \$@

clean:
	\$(RM) \$(OBJS)
	@if [ -d "\$(LIBFT_DIR)" ]; then \$(MAKE) -C \$(LIBFT_DIR) clean; fi

fclean: clean
	\$(RM) \$(NAME)
	@if [ -d "\$(LIBFT_DIR)" ]; then \$(MAKE) -C \$(LIBFT_DIR) fclean; fi

re: fclean all

.PHONY: all clean fclean re
EOF
        else
            # Standard Makefile WITHOUT Library
            cat << EOF > Makefile
NAME        = $DIR_NAME

# SRCS_START
SRCS        = 
# SRCS_END

OBJS        = \$(SRCS:.c=.o)
INCLUDES    = $DIR_NAME.h

CC          = cc
CFLAGS      = -Wall -Wextra -Werror -I.
RM          = rm -f

all: \$(NAME)

\$(NAME): \$(OBJS)
	\$(CC) \$(CFLAGS) \$(OBJS) -o \$(NAME)

%.o: %.c \$(INCLUDES)
	\$(CC) \$(CFLAGS) -c $< -o \$@

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
# Python Project Setup
# ------------------------------------------------------------------------------
elif [ "$LANG_CHOICE" -eq 2 ]; then
    echo -e "\033[34m[+] Setting up Python project structure...\033[0m"
    
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
    touch requirements.txt
fi

# ------------------------------------------------------------------------------
# README.md Generation
# ------------------------------------------------------------------------------
if [[ "$NEED_README" =~ ^[Yy]$ ]]; then
    echo -e "\033[34m[+] Creating README.md...\033[0m"
    cat << EOF > README.md
*This project has been created as part of the 42 curriculum by $USERS.*
 
# $DIR_NAME
 
## Description
 
<!-- Goal of the project, short overview and allowed external functions. -->

## Project Files

<!-- FILES_START -->
<!-- FILES_END -->
 
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

echo ""
echo -e "\033[32m✨ Workspace for '$DIR_NAME' successfully created for [$USERS]!\033[0m"
