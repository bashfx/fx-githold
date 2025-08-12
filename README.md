# 🗄️ githold — Quickly Create and Link a GitHub Repo

**githold** is a simple Bash utility to create a new GitHub repository (locally and remotely) in seconds.  
It uses your SSH identity style (`git@SSH_IDENTITY:user/repo.git`) and can either create the remote automatically using [GitHub CLI](https://cli.github.com/) or give you manual instructions.

It’s perfect when you want to:
- Secure a GitHub repo name before someone else does.
- Bootstrap a new project and push it to GitHub instantly.
- Keep a consistent repo setup workflow with SSH aliases.

---

## ✨ Features
- 🖥 **Banner output** every run for style (disable with `--quiet`)
- 🚀 Creates local repo + sets remote URL
- ⚙️ Works with any GitHub username/org
- 🔒 Private or public repo creation
- 🛠 Automatic remote creation if `gh` CLI is available
- 📜 Manual instructions if not

---

## 🛠️ Usage

```bash
./githold <repo-name> [flags...]
```

### 🏴 Flags
| Flag | Description |
|------|-------------|
| `--dir DIRNAME`     | Local directory name (default = repo name) |
| `--name USER_OR_ORG`| GitHub username/org (default from script) |
| `--ssh SSH_HOST`    | SSH alias or domain (default: `github.com`) |
| `--private`         | Make repo private (default) |
| `--public`          | Make repo public |
| `--yes`             | Skip confirmation prompt |
| `--quiet`           | Suppress banner output |
| `-h, --help`        | Show usage help |

---

## 📦 Example Commands

Create a private repo `coolproject` in the default GitHub account:
```bash
./githold coolproject --yes
```

Create a public repo for an organization:
```bash
./githold toolkit \
  --name myorg \
  --public \
  --yes
```

Create in a custom directory, using SSH alias `github`:
```bash
./githold myrepo \
  --dir ~/projects/testdir \
  --ssh github \
  --yes
```

---

## 📜 Example Output

```
 ______     __     ______                  
/\  ___\   /\ \   /\__  _\                 
\ \ \__ \  \ \ \  \/_/\ \/                 
 \ \_____\  \ \_\    \ \_\                 
  \/_____/   \/_/     \/_/                 
                                           
 __  __     ______     __         _____    
/\ \_\ \   /\  __ \   /\ \       /\  __-.  
\ \  __ \  \ \ \/\ \  \ \ \____  \ \ \/\ \ 
 \ \_\ \_\  \ \_____\  \ \_____\  \ \____- 
  \/_/\/_/   \/_____/   \/_____/   \/____/ 

────────────────────────────────────────────
Plan:
  Local Dir:    coolproject
  Repo Name:    coolproject
  GitHub Name:  mygithub
  Visibility:   private
  HTTPS URL:    https://github.com/mygithub/coolproject
  SSH URL:      git@github.com:mygithub/coolproject.git

Proceed with repo creation? [y/N]: y
Remote repo created: https://github.com/mygithub/coolproject
Done.
```

---

## 🔧 Requirements
- **Git** installed and available in your `$PATH`.
- **GitHub CLI** (`gh`) for automatic remote creation (optional).
- SSH key configured for GitHub if using SSH remote.

---

## 🛡️ License
MIT or Apache-2.0 — your choice.
