#!/bin/bash

# ==============================================================================
# SECTION 1: Argument Validation & Parameter Processing
# ==============================================================================
if [ "$#" -lt 1 ]; then
    echo -e "\033[31mError: Not enough arguments.\033[0m"
    echo "Usage: $0 <project_name> [git_url|local] [\"user1, user2\"]"
    echo "Examples:"
    echo "  Single (Local): $0 Libft"
    echo "  Single (Git):   $0 Libft git@vogsphere.42madrid.fr:vogsphere/..."
    echo "  Group (Local):  $0 push_swap local \"login1, login2\""
    echo "  Group (Git):    $0 Cub3D git@vogsphere... \"login1, login2\""
    exit 1
fi

DIR_NAME="$1"
GIT_OPTION="${2:-local}"         # Default to 'local' if $2 is omitted
USERS="${3:-legomez}"            # Default author if $3 is omitted

# Header guard formatted in uppercase (e.g., LIBFT_H)
HEADER_GUARD="$(echo "$DIR_NAME" | tr '[:lower:]' '[:upper:]')_H"

# ==============================================================================
# SECTION 2: Repository or Directory Setup
# ==============================================================================
# Checks if $GIT_OPTION is a Git URL (starts with git@ or http)
if [[ "$GIT_OPTION" =~ ^(git@|http) ]]; then
    echo -e "\033[34m[+] Cloning repository...\033[0m"
    git clone "$GIT_OPTION" "$DIR_NAME"
    if [ $? -ne 0 ]; then
        echo -e "\033[31mError: Failed to clone repository.\033[0m"
        exit 1
    fi
else
    echo -e "\033[34m[+] Creating local workspace: $DIR_NAME...\033[0m"
    mkdir -p "$DIR_NAME"
fi

cd "$DIR_NAME" || exit 1

# ==============================================================================
# SECTION 3: Header File Generation (.h)
# ==============================================================================
echo -e "\033[34m[+] Creating $DIR_NAME.h...\033[0m"

cat << EOF > "$DIR_NAME.h"
#ifndef $HEADER_GUARD
# define $HEADER_GUARD

# include <unistd.h>
# include <stdlib.h>

/* Project: $DIR_NAME */
/* Author(s): $USERS */

#endif
EOF

# ==============================================================================
# SECTION 4: Root Makefile Generation
# ==============================================================================
echo -e "\033[34m[+] Creating Makefile...\033[0m"

cat << EOF > Makefile
NAME        = $DIR_NAME

# Add your .c files to SRCS
SRCS        := 

OBJS        = \$(SRCS:.c=.o)
INCLUDES    = $DIR_NAME.h

CC          = cc
CFLAGS      = -Wall -Wextra -Werror -I.

all: \$(NAME)

\$(NAME): \$(OBJS)
	\$(CC) \$(CFLAGS) \$(OBJS) -o \$(NAME)

%.o: %.c \$(INCLUDES)
	\$(CC) \$(CFLAGS) -c $< -o \$@

clean:
	rm -f \$(OBJS)

fclean: clean
	rm -f \$(NAME)

re: fclean all

.PHONY: all clean fclean re
EOF

# ==============================================================================
# SECTION 5: README.md Generation
# ==============================================================================
echo -e "\033[34m[+] Creating README.md...\033[0m"

cat << EOF > README.md
# $DIR_NAME

*This project has been created as part of the curriculum of 42 by $USERS*

## Description


## Instructions


## Resources

EOF

echo -e "\033[32m✨ Workspace for '$DIR_NAME' successfully created for [$USERS]!\033[0m"
