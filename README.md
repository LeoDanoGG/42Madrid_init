# 42 Project Initializer (`42init` for 42 Cursus)

A Bash script designed for 42 School students to instantly scaffold project workspaces, clone Vogsphere/GitHub repositories, generate a project header (`.h`), and construct a root `Makefile` alongside a base `README.md`. It also includes a `make upload` rule that keeps your `SRCS` list and your README file listing in sync with the `.c` files in your project.

## 🛠️ Key Features & Architecture

1. **Argument Validation & Dual Mode Setup:** Supports both local directory creation and remote repository cloning (Vogsphere/GitHub). Seamlessly handles single or group projects by parsing user logins.
2. **Dynamic Header File Generation (`.h`):** Creates a project header file (e.g., `Libft.h`) formatted with standard uppercase header guards (`#ifndef LIBFT_H`), base libraries (`unistd.h`, `stdlib.h`), and project metadata.
3. **Structured Root Makefile:** Generates a clean `Makefile` configured with `-I.` in `CFLAGS` to locate your headers and links `$(INCLUDES)` as a dependency to trigger recompilation when `.h` files are modified.
4. **Automatic Source Tracking (`make upload`):** Scans the project root for `.c` files, rewrites the `SRCS` variable in the `Makefile` (5 files per line) and refreshes the file list inside the `README.md`. It runs automatically once at project creation, so any `.c` files already present in a cloned repository are picked up from the start.
5. **Customizable Documentation:** Creates a tailored `README.md` referencing project authors and structure.

## 🚀 How to Use

### ⚙️ Global Installation & Setup (Alias)

Instead of keeping the script on your Desktop and executing it with absolute paths, you can configure it as a **global command** (`42init`). This allows you to generate new projects instantly from any directory in your terminal.

1. **Move the script to a dedicated folder in your home directory:**
```
   mkdir -p ~/scripts
   mv ~/Desktop/42init.sh ~/scripts/42init.sh
```
2. **Grant execution permissions:**
```
   chmod +x ~/scripts/42init.sh
```
3. **Configure the alias for your shell:**
 - Option A: Zsh (Default Shell)
```
   echo "alias 42init='~/scripts/42init.sh'" >> ~/.zshrc
```
 - Option B: Fish Shell
```
   alias 42init='~/scripts/42init.sh'
   funcsave 42init
```
4. **Reload your terminal configuration (Zsh):**
```
   source ~/.zshrc
```

> 💡 **Default Author Note:** The script uses `legomez` as the default author login. You can change it directly inside `42init.sh` or run this command in your terminal to replace it with your own login:
>
> ```
> sed -i.bak 's/USERS="${3:-legomez}"/USERS="${3:-YOUR_LOGIN}"/' ~/scripts/42init.sh && rm -f ~/scripts/42init.sh.bak
> ```

### 💻 Execution Syntax

```
42init <project_name> [git_url|local] ["user1, user2"]
```

#### Examples

- **Single Project (Local):**
```
  42init Libft
```
   *Creates directory `Libft/` with `Libft.h`, a configured `Makefile`, and a base `README.md`.*
- **Single Project (Git Remote):**
```
  42init Libft git@vogsphere.42madrid.fr:vogsphere/piscine-c-libft-user...
```
   *Clones the remote repository into `Libft/` before setting up header and build files. Any `.c` files already in the repository root are added to `SRCS` automatically.*
- **Group Project (Local):**
```
  42init Cub3D local "login1, login2"
```
   *Generates a local workspace attributing authorship to multiple students in the header and `README.md`.*
- **Group Project (Git Remote):**
```
  42init Cub3D git@vogsphere.42madrid.fr:... "login1, login2"
```

## 🛠️ Build Commands & Important Notes

Inside the generated project directory, you no longer need to edit `SRCS` by hand: add your `.c` files to the project root and run `make upload`.

- `make` – Compiles all `.c` files listed in `SRCS` into the binary.
- `make clean` / `make fclean` / `make re` – Standard 42 rule lifecycle for object files and executable.
- `make upload` – Scans the project root (no subdirectories) for `.c` files, then:
  - rewrites the `SRCS` block of the `Makefile`, grouped 5 files per line;
  - replaces the file list inside the `README.md` under **Project Files**.

### 📌 How `make upload` works

The rule only edits the content **between markers**, so the rest of your files are never touched:

| File | Start marker | End marker |
|------|--------------|------------|
| `Makefile` | `# SRCS_START` | `# SRCS_END` |
| `README.md` | `<!-- FILES_START -->` | `<!-- FILES_END -->` |

> ⚠️ **Do not delete or rename these markers.** If a marker is missing, `make upload` will not be able to update that file. Anything you write between the markers will be overwritten on the next run; write your own notes outside of them.
---
> ⚠️ **Makefile tabs:** recipe lines in a Makefile must start with a real **TAB**, not spaces. If you edit the generated `Makefile` and see `missing separator`, that is almost always the cause.
---
> ⚠️ **Norm reminder:** `upload` is a convenience rule for your day-to-day workflow. Check that its use is allowed in your project's subject and evaluation rules, and that the final `SRCS` in your delivered `Makefile` lists only the files the subject permits (no wildcards).
---
> ⚠️ **42 Norminette & Header Reminder:** This script creates the basic structural files to speed up project initialization. Remember that you **must manually insert the official 42 Header** (`:Stdheader` in Vim / using the extension in VS Code) at the top of all your `.c`, `.h`, and `Makefile` files to comply with Norminette guidelines.
