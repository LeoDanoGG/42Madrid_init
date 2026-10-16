# 42 Project Initializer (`42init` for 42 Cursus)

An interactive CLI assistant (*wizard*) for 42 School students to quickly scaffold project workspaces, clone Vogsphere/GitHub repositories, generate language-specific boilerplate (C & Python), and keep your source files synchronized between the `Makefile` and the `README.md`.

## Table of contents

- [Key features](#key-features)
- [Requirements](#requirements)
- [Installation](#installation)
- [How to use](#how-to-use)
- [Syncing existing projects](#syncing-existing-projects)
- [Limitations](#limitations)
- [Important reminders](#important-reminders)

---

## Key features

1. **Interactive CLI wizard:** launch `42init` and answer simple prompts with safe defaults. Invalid answers are rejected and asked again.
2. **Two modes:**
   - **Create / Scaffold:** sets up a brand-new C or Python workspace.
   - **Sync / Update:** scans the current directory for `.c` files and updates both the `Makefile` and the `README.md`. A shortcut is available: `42init sync`.
3. **C and Python support:**
   - **C:** header file (`.h`) with a valid uppercase include guard, a `Makefile` with `-Wall -Wextra -Werror`, header dependency tracking, and optional linking against your own `libft`.
   - **Python:** an executable `main.py` entrypoint and an empty `requirements.txt`.
4. **Non-destructive:** files that already exist (`.h`, `Makefile`, `README.md`, `main.py`) are never overwritten; the script tells you which ones it skipped. It is safe to run on a cloned repository.
5. **Clean source grouping:** `.c` files are listed 5 per line with aligned continuation lines in the `Makefile` and inside a code block in the `README.md`.
6. **Tailored documentation:** the `README.md` template covers description, architecture, usage, testing, resources and AI usage disclosure.
7. **Automatic author:** the default author is your current login (`$USER`); you can type other logins for group projects.

---

## Requirements

- `bash`, `git`, and standard Unix tools (`awk`, `sed`, `find`)
- macOS or Linux (written and tested with portable syntax, no GNU-only flags)

---

## Installation

Clone the repository once and point a global alias at the script. Updating is then a simple `git pull`.

1. **Clone it:**
   ```bash
   mkdir -p ~/scripts
   git clone https://github.com/LeoDanoGG/42Madrid_init ~/scripts/42init
   chmod +x ~/scripts/42init/42init.sh
   ```

2. **Create the alias for your shell:**

   - **Zsh** (default shell on 42 Macs):
     ```bash
     echo "alias 42init='~/scripts/42init/42init.sh'" >> ~/.zshrc
     source ~/.zshrc
     ```

   - **Fish:**
     ```fish
     alias 42init='$HOME/scripts/42init/42init.sh'
     funcsave 42init
     ```
     `funcsave` persists the alias for all future sessions.

3. **Update later:**
   ```bash
   git -C ~/scripts/42init pull
   ```

> 💡 **Default author:** the script uses your current login (`$USER`) when you just press Enter at the author prompt. No editing needed.

---

## How to use

Run the command from the directory where you want the project folder to be created:

```bash
42init
```

### Interactive flow

1. **Action:**
   1. Create / Scaffold a new project
   2. Sync / Update `.c` files in the current directory *(Makefile & README)*
2. **Project name:** letters, digits, `.`, `_` and `-` only (no spaces or slashes).
3. **Repository setup:** local directory, or Git clone (`git@vogsphere...` / GitHub). The URL is required if you choose to clone.
4. **Author login(s):** credited in `README.md` (and in `main.py` for Python projects). Default: your `$USER`.
5. **Language:**
   1. C (Common Core / Piscine)
   2. Python (Common Core)
6. **C options** *(only if C is selected)*:
   - Generate a `Makefile`? `[Y/n]`
   - Link against your own `libft` (`./libft`)? `[y/N]`
7. **Documentation:** generate `README.md`? `[Y/n]`

If you cloned a repository that already contains `.c` files in its root, they are added to `SRCS` and to the README list automatically.

### About the `libft` option

The generated `Makefile` expects your library in `./libft`, with its own `Makefile` producing `libft.a`. It adds `-I./libft`, links with `-L./libft -lft`, and runs `make -C libft` on every build, so changes in your library are picked up. A second `make` with nothing changed does not relink the project. Other libraries (e.g. MLX) are not generated: add their flags to the `Makefile` by hand.

---

## Syncing existing projects

Once you have added or removed `.c` files in your project root, you do not need to edit `SRCS` or the README list by hand:

```bash
cd my_project
42init sync
```

*(Or run `42init` and choose option 2.)*

The script scans for `.c` files, groups them 5 per line, and rewrites only what is **between the markers**:

| File			| Start marker				| End marker			|
|---------------|---------------------------|-----------------------|
| `Makefile`	| `# SRCS_START`			| `# SRCS_END`			|
| `README.md`	| `<!-- FILES_START -->`	| `<!-- FILES_END -->`	|

If a file or its markers are missing, that file is skipped with a warning and nothing else is touched. Running sync repeatedly gives the same result.

> If you cloned a repository that already had its own `README.md`, the script will not overwrite it. To use sync with it, add the two README markers wherever you want the list to appear.

---

## Limitations

- Sync only scans the **project root** (no subdirectories such as `src/`).
- Sync only handles **`.c` files**. Python projects do not use markers.
- Every `.c` in the root is listed, including test files such as a throwaway `main.c`. Remove them before syncing if the subject does not allow them.
- Anything you write between the markers is replaced on the next sync. Keep your own notes outside of them.

---

## Important reminders

> ⚠️ **Preserve the markers.** Do not delete or rename `# SRCS_START` / `# SRCS_END` in the `Makefile` or `<!-- FILES_START -->` / `<!-- FILES_END -->` in the `README.md`.

> ⚠️ **Makefile tabs.** Recipe lines must start with a real TAB. If you edit the generated `Makefile` and get `missing separator`, your editor probably converted tabs into spaces.

> ⚠️ **42 header.** This script creates structural boilerplate only. Insert the official 42 header (`:Stdheader` in Vim / VS Code extension) at the top of your `.c`, `.h` and `Makefile` files, as your subject and evaluation require. Norminette itself checks `.c` and `.h` files; check your subject for the rest.

> ⚠️ **Check the subject.** The generated files are a starting point. Always verify the final `Makefile` and `README.md` against the requirements of your specific project.
