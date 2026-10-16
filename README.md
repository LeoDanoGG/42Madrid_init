# 42 Project Initializer (`42init` for 42 Cursus)

An interactive CLI assistant (*wizard*) designed for 42 School students to quickly scaffold project workspaces, clone Vogsphere/GitHub repositories, generate language-specific boilerplate (C & Python), and keep source files synchronized between `Makefile` and `README.md`.

Index
 - [Key features & architecture](##🛠️-Key-features-&-architecture)
 - [Global installation & setup](##⚙️-Global-installation-&-setup-(alias))
 - [How to use](##🚀-How-to-use)
 - [Updating existing projects](##🔄-Updating-existing-projects-(`Sync`-mode))
 - [Important reminders](##⚠️-Important-42-guidelines-&-reminders)

---

## 🛠️ Key features & architecture

1. **Interactive CLI Wizard:**  
   Launch `42init` and answer simple terminal prompts with safe default values. No need to memorize complex syntax or flags.
2. **Dual Operation Modes:**
   - **Mode 1 (Create/Scaffold):** Sets up brand-new C or Python workspaces.
   - **Mode 2 (Sync/Update):** Scans an existing project for `.c` files and updates both the `Makefile` and `README.md` without leaving extra rules or code artifacts in your build files.
3. **Multi-Language Support (C & Python):**
   - **C Projects:** Generates dynamic header files (`.h`) with uppercase header guards, standard 42-compliant `Makefile`s (with optional static library linkage like `libft`), and clean source structure.
   - **Python Projects:** Generates a clean executable `main.py` entrypoint and a base `requirements.txt` for 42 Common Core Python modules.
4. **Clean Source Grouping (5 files per line):**  
   Automatically formats `.c` files in groups of 5 with proper alignment (`SRCS = ... \`) inside `Makefile`s and inside Markdown code blocks in `README.md`.
5. **Tailored 42 Documentation:**  
   Produces a detailed `README.md` template covering description, architecture/algorithms, usage, testing, resources, and AI tool usage disclosures.

---

## ⚙️ Global installation & setup (alias)

To run `42init` from any working directory in your terminal, move the script to a dedicated directory and create a global alias according to your shell.

1. **Move the script and grant execution permissions:**
   ```bash
   mkdir -p ~/scripts
   mv ~/Desktop/42init.sh ~/scripts/42init.sh
   chmod +x ~/scripts/42init.sh
   ```

2. **Configure the alias for your shell:**
* **Option A: Zsh (Default 42 Mac Shell)**
   ```bash
   echo "alias 42init='~/scripts/42init.sh'" >> ~/.zshrc
   source ~/.zshrc
   ```

* **Option B: Fish Shell**
   ```fish
   alias 42init='~/scripts/42init.sh'
   funcsave 42init
   ```

3. **Reload your shell session:**
   * **Zsh:** Run `source ~/.zshrc` or open a new terminal tab.
   * **Fish:** `funcsave` persists the alias automatically across all future sessions.

   > 💡 **Default Author Note:**
   > The script uses `legomez` as the default author login. You can change it directly inside `42init.sh` or run this command in your terminal to replace it with your own login:
   > ```bash
   > sed -i '' 's/USERS="${USERS:-legomez}"/USERS="${USERS:-YOUR_LOGIN}"/' ~/scripts/42init.sh
   > ```

---

## 🚀 How to use

Simply run the global command from any directory in your terminal:

```bash
42init
```

### 📋 Interactive flow overview

When executed, `42init` will guide you through the following prompt sequence:

1. **Action Selection:**
* `1) Create / Scaffold a new project`
* `2) Sync / Update .c files in current directory` *(Updates Makefile & README)*

2. **Project Name:** Name of the folder to create.
3. **Repository Setup:** Local directory vs. Git clone (`git@vogsphere...` / GitHub).
4. **Author Login(s):** Authors credited in headers and `README.md`.
5. **Language Selection:**
* `1) C (Common Core / Piscine)`
* `2) Python (Common Core)`

6. **C Configuration (if C selected):**
* Generate `Makefile`? `[Y/n]`
* Include external/static library support (e.g. `libft` / `MLX`)? `[y/N]`


7. **Documentation:** Generate `README.md`? `[Y/n]`

---

## 🔄 Updating existing projects (`Sync` mode)

Once you have written or added new `.c` files in your project root, you do **not** need to manually edit your `Makefile` or `README.md`:

1. Open your terminal in the project root folder.
2. Run `42init`.
3. Choose **Option 2 (Sync / Update)**.

The script will scan for `.c` files, group them 5 per line with precise alignment, and update the contents between the `# SRCS_START` / `# SRCS_END` tags in `Makefile` and `<!-- FILES_START -->` / `<!-- FILES_END -->` tags in `README.md`.

---

## ⚠️ Important 42 guidelines & reminders

> ⚠️ **Preserve Structural Markers:**
> Do not delete `# SRCS_START` / `# SRCS_END` in `Makefile` or `<!-- FILES_START -->` / `<!-- FILES_END -->` in `README.md`. The sync mode uses these exact tags to update your source files safely.

> ⚠️ **42 Norminette & Header Reminder:**
> This script creates structural boilerplate to speed up your workflow. You **must manually insert the official 42 Header** (`:Stdheader` in Vim / VS Code extension shortcut) at the top of all `.c`, `.h`, and `Makefile` files to comply with Norminette rules.
