#!/usr/bin/env bash
# githold — init a local git repo, set remote, and verify if the remote exists
# Bash 3.2+ compatible

set -euo pipefail

# ==================== DEFAULTS ==================== #
DEFAULT_GITHUB_NAME="YourGitHubUsernameOrOrg"       # override with --name
DEFAULT_SSH_IDENTITY="${SSH_IDENTITY:-github.com}"  # override with --ssh
# =================================================== #

# colors
CLR_RESET="$(printf '\033[0m')"
CLR_CYAN_B="$(printf '\033[1;36m')"
CLR_GREEN_B="$(printf '\033[1;32m')"

hr(){ local cols; cols=$(tput cols 2>/dev/null || echo 80); printf "%s\n" "$(printf '%*s' "$cols" '' | tr ' ' '─')"; }

die(){ echo "ERR: $*" >&2; exit 1; }

usage(){
  cat <<USAGE
Usage: $0 <repo-name>
       [--dir DIRNAME]         # local directory name (defaults to repo name)
       [--name USER_OR_ORG]    # GitHub username/org (default: ${DEFAULT_GITHUB_NAME})
       [--ssh SSH_HOST]        # SSH alias/domain (default: ${DEFAULT_SSH_IDENTITY})
       [--yes]                 # skip confirmation
       [--quiet]               # suppress banner
USAGE
  exit 1
}


clear_screen(){
  # clear screen
  printf '\033[2J\033[H'
}


print_banner(){
  printf "%s" "$CLR_CYAN_B"
  cat <<'BANNER'

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

BANNER
  printf "%s" "$CLR_RESET"
}

# --------- parse ---------
[ $# -ge 1 ] || usage
REPO_NAME="$1"; shift

DIR_NAME=""
GITHUB_NAME="$DEFAULT_GITHUB_NAME"
SSH_ID="$DEFAULT_SSH_IDENTITY"
AUTO_YES="no"
QUIET="no"

while [ $# -gt 0 ]; do
  case "$1" in
    --dir) DIR_NAME="${2:?}"; shift 2;;
    --name) GITHUB_NAME="${2:?}"; shift 2;;
    --ssh) SSH_ID="${2:?}"; shift 2;;
    --yes) AUTO_YES="yes"; shift;;
    --quiet) QUIET="yes"; shift;;
    -h|--help) usage;;
    *) die "Unknown arg: $1";;
  esac
done

# --------- validations ---------
[ -n "$REPO_NAME" ] || die "repo name required"
case "$REPO_NAME" in *[\\/:]*|"") die "invalid repo name" ;; esac
[ -n "$GITHUB_NAME" ] || die "--name required or set DEFAULT_GITHUB_NAME"
[ "$GITHUB_NAME" != "YourGitHubUsernameOrOrg" ] || die "set --name or DEFAULT_GITHUB_NAME"

[ -n "$DIR_NAME" ] || DIR_NAME="$REPO_NAME"
[ ! -e "$DIR_NAME" ] || die "directory '$DIR_NAME' already exists"

REPO_HTTPS="https://github.com/${GITHUB_NAME}/${REPO_NAME}"
REPO_SSH="git@${SSH_ID}:${GITHUB_NAME}/${REPO_NAME}.git"

clear_screen;

# --------- banner ---------
[ "$QUIET" = "yes" ] || print_banner

# --------- pre-flight summary (aligned with cargohold) ---------
hr
echo "Plan:"
printf "  Local Dir:    %s\n" "$DIR_NAME"
printf "  Repo Name:    %s\n" "$REPO_NAME"
printf "  GitHub Name:  %s\n" "$GITHUB_NAME"
printf "  Repo HTTPS:   %s\n" "$REPO_HTTPS"
printf "  Remote SSH:   %s\n" "$REPO_SSH"
echo

# --------- confirmation (same prompt wording as cargohold) ---------
if [ "$AUTO_YES" != "yes" ]; then
  printf "Proceed with creation? [y/N]: "
  read ans || true
  ans=$(printf '%s' "${ans:-}" | tr '[:upper:]' '[:lower:]')
  if [ "$ans" != "y" ] && [ "$ans" != "yes" ]; then
    echo "Aborted."
    exit 0
  fi
fi

# --------- local setup ---------
mkdir -p "$DIR_NAME"
cd "$DIR_NAME"
git init -q
git checkout -q -b main 2>/dev/null || true

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REPO_SSH"
else
  git remote add origin "$REPO_SSH"
fi

# --------- remote existence check ---------
if git ls-remote --exit-code "$REPO_SSH" >/dev/null 2>&1; then
  printf "%sRemote exists:%s %s\n" "$CLR_GREEN_B" "$CLR_RESET" "$REPO_SSH"
else
  echo "Remote NOT found: $REPO_SSH"
  echo "Create the repository on your remote host, then push:"
  echo "  git add . && git commit -m \"init\""
  echo "  git push -u origin HEAD"
fi

printf "%sLocal repo setup complete.%s\n" "$CLR_GREEN_B" "$CLR_RESET"
