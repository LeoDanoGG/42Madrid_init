#!/bin/bash

# ==============================================================================
# SECTION 1: Argument Validation & Parameter Processing
# ==============================================================================
if [ "$#" -lt 1 ]; then
    echo -e "\033[31mError: Not enough arguments.\033[0m"
    echo "Usage: $0 <project_name> [git_url|local] [\"user1, user2\"]"
    exit 1
fi

DIR_NAME="$1"
GIT_OPTION="${2:-local}"
USERS="${3:-legomez}"
HEADER_GUARD="$(echo "$DIR_NAME" | tr '[:lower:]' '[:upper:]')_H"

# ==============================================================================
# SECTION 2: Repository or Directory Setup
# ==============================================================================
if [[ "$GIT_OPTION" =~ ^(git@|http) ]]; then
    echo -e "\033[34m[+] Cloning repository...\033[0m"
    git clone "$GIT_OPTION" "$DIR_NAME" || { echo -e "\033[31mError: Failed to clone repository.\033[0m"; exit 1; }
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
# SECTION 4: Makefile Generation (IMPORTANT: recipe lines start with a TAB)
# ==============================================================================
echo -e "\033[34m[+] Creating Makefile...\033[0m"

cat << 'EOF' > Makefile
NAME        = DIR_NAME_PLACEHOLDER

# SRCS_START
# SRCS_END

OBJS        = $(SRCS:.c=.o)
INCLUDES    = DIR_NAME_PLACEHOLDER.h

CC          = cc
CFLAGS      = -Wall -Wextra -Werror -I.

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)

%.o: %.c $(INCLUDES)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

# Updates SRCS (between markers) and the file list in README.md
upload:
	@LIST=$$(find . -maxdepth 1 -name '*.c' | sed 's|^\./||' | sort | xargs -n 5); \
	BLOCK=$$(echo "$$LIST" | sed '1s/^/SRCS        = /; 2,$$s/^/              /; s/$$/ \\/; $$s/ \\$$//'); \
	BLOCK="$$BLOCK" awk '/^# SRCS_END$$/{skip=0} !skip{print} /^# SRCS_START$$/{skip=1; print ENVIRON["BLOCK"]}' Makefile > Makefile.tmp && mv Makefile.tmp Makefile; \
	if [ -f README.md ]; then \
		LIST="$$LIST" awk '/^<!-- FILES_END -->$$/{skip=0} !skip{print} /^<!-- FILES_START -->$$/{skip=1; print "```c"; print ENVIRON["LIST"]; print "```"}' README.md > README.tmp && mv README.tmp README.md; \
	fi; \
	echo "✨ Makefile & README.md updated with current .c files!"

.PHONY: all clean fclean re upload
EOF

sed -i.bak "s/DIR_NAME_PLACEHOLDER/$DIR_NAME/g" Makefile && rm -f Makefile.bak

# ==============================================================================
# SECTION 5: README.md Generation
# ==============================================================================
echo -e "\033[34m[+] Creating README.md...\033[0m"

cat << EOF > README.md
# $DIR_NAME

*This project has been created as part of the curriculum of 42 by $USERS*

## Description


## Project Files

<!-- FILES_START -->
<!-- FILES_END -->

## Instructions


## Resources

EOF

# Fill SRCS and the README list with whatever .c files already exist
make upload

echo -e "\033[32m✨ Workspace for '$DIR_NAME' successfully created for [$USERS]!\033[0m"
