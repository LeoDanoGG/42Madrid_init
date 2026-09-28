# 42 Project Initializer (`42init` for 42 cursus)

A Bash script designed for 42 School students to instantly scaffold project workspaces, clone Vogsphere/GitHub repositories and construct a root `Makefile` alongside a base `README.md`.

---

## 🛠️ Key Features & Architecture

1. **Argument Validation & Dual Mode Setup:**
Supports both local directory creation and remote repository cloning (Vogsphere/GitHub). Seamlessly handles single or group projects by parsing user logins.
2. **Wildcard Root Makefile:**
Generates a `Makefile` at the project root using `wildcard` (`ex*/*.c`) to automatically detect and compile `.c` files across all exercises.
3. **Customizable Documentation:**
Creates a tailored `README.md` referencing project authors and structure.

---

## 🚀 How to Use

## ⚙️ Global Installation & Setup (Alias)

Instead of keeping the script on your Desktop and executing it with absolute paths, you can configure it as a **global command** (`42init`). This allows you to generate new projects instantly from any directory in your terminal.

### Step-by-Step Setup

1. **Move the script to a dedicated folder in your home directory:**
```bash
mkdir -p ~/scripts
mv ~/Desktop/42init.sh ~/scripts/42init.sh

```


2. **Grant execution permissions:**
```bash
chmod +x ~/scripts/42init.sh

```


3. **Add a permanent alias to your shell configuration (`~/.zshrc`):**
*(42 Mac workstations use `zsh` by default)*
```bash
echo "alias 42init='~/scripts/42init.sh'" >> ~/.zshrc

```


4. **Reload your terminal configuration:**
```bash
source ~/.zshrc

```

### 💡 Workflow Impact

Once configured, navigate to any working directory (such as `~/sgoinfre` or your projects folder) and run it.

---

### 2. Execution Syntax

```bash
42init <project_name> [git_url|local] ["user1, user2"]

```

#### Examples

* **Single Project (Local):**
```bash
42init C02

```


*Creates directory `C02/` with `ex00`–`ex09`, a wildcard `Makefile`, and a default `README.md`.*
* **Single Project (Git Remote):**
```bash
42init C02 git@vogsphere.42madrid.fr:vogsphere/piscine-c-c02-user...

```


*Clones the remote repository into `C02/` before setting up subfolders and build files.*
* **Group Project (Local):**
```bash
42init Cub3D local "login1, login2"

```


*Generates a local workspace attributing authorship to multiple students in the `README.md`.*
* **Group Project (Git Remote):**
```bash
42init Cub3D git@vogsphere.42madrid.fr:... "login1, login2"

```



---

## 🛠️ Build Commands

Inside the generated project directory, you can manage your build using the root `Makefile`:

* `make` – Compiles all `.c` files found in `ex**/*.c` into the main executable.
* `make status` – Displays all `.c` source files currently detected by the wildcard rule.
* `make clean` / `make fclean` / `make re` – Standard 42 rule lifecycle for object files and binaries.
