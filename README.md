# 42 Project Initializer (`42init`)

A Bash script designed for 42 School students to instantly scaffold project directories, clone repositories, generate exercise folders (`ex00`, `ex01`, ...), and build a base `README.md`.

---

## 🛠️ Main Sections of the Script

1. **Argument Parsing & Repository Setup:**
Checks input arguments and either clones a remote Git repository (e.g., Vogsphere/GitHub) into your target directory or creates a new local folder if no URL is provided.
2. **Subdirectory Generator (`exXX`):**
Iterates from `0` to your specified number of exercises, creating padded subfolders (`ex00`, `ex01`, etc.) formatted to match 42 standards.
3. **Documentation Generator (`README.md`):**
Creates a standard `README.md` file inside the root directory containing the project name and an overview of the exercise structure.

---

## 🚀 How to Use

### 1. Requirements & Setup

Make the script executable and (optionally) add an alias to your `~/.zshrc`:

```bash
chmod +x init_proj.sh
echo "alias 42init='~/path/to/init_proj.sh'" >> ~/.zshrc
source ~/.zshrc

```

### 2. Execution Syntax

```bash
# General syntax
42init <directory_name> <number_of_exercises> [git_url]

```

* **Local creation (without Git):**
```bash
42init C02 8

```


*Creates directory `C02/` with subfolders `ex00` through `ex07` and a `README.md`.*
* **Remote creation (with Git clone):**
```bash
42init C02 8 git@vogsphere.42madrid.fr:vogsphere/piscine-c-c02-user...

```


*Clones the remote repo into `C02/`, then generates `ex00`–`ex07` and `README.md` inside it.*
