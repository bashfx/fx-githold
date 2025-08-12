#!/usr/bin/env bash
# githold — create and link a new GitHub/Lab repo via CLI or manual instructions
# Bash 3.2+ compatible

set -euo pipefail

# Defaults
DEFAULT_GITHUB_NAME="YourGitHubUsernameOrOrg"     # override with --name
DEFAULT_SSH_IDENTITY="${SSH_IDENTITY:-github.com}"# override with --ssh
DEFAULT_PRIVATE="yes"
AUTO_YES="no"

die(){ echo "ERR: $*" >&2; exit 1; }

usage(){
  cat <<USAGE
Usage: $0 <repo-name>
       [--dir DIRNAME]       # local directory name (defaults to repo name)
       [--name GITHUB_USER_OR_ORG]
       [--ssh SSH_HOST_ALIAS_OR_DOMAIN]
       [--private|--public]
       [--yes]               # skip confirmation
Notes:
  - Requires GitHub CLI (gh) for automatic remote creation.
  - If gh is missing, script will output manual creation instructions.
USAGE
  exit 1
}

# --------- parse ---------
[ $# -ge 1 ] || usage
REPO_NAME="$1"; shift
DIR_NAME=""        # local folder

GITHUB_NAME="$DEFAULT_GITHUB_NAME"
SSH_ID="$DEFAULT_SSH_IDENTITY"
PRIVATE="$DEFAULT_PRIVATE"

while [ $# -gt 0 ]; do
  case "$1" in
    --dir) DIR_NAME="${2:?}"; shift 2;;
    --name) GITHUB_NAME="${2:?}"; shift 2;;
    --ssh) SSH_ID="${2:?}"; shift 2;;
    --private) PRIVATE="yes"; shift;;
    --public) PRIVATE="no"; shift;;
    --yes) AUTO_YES="yes"; shift;;
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

# --------- summary ---------
echo "Plan:"
printf "  Local Dir:    %s\n" "$DIR_NAME"
printf "  Repo Name:    %s\n" "$REPO_NAME"
printf "  GitHub Name:  %s\n" "$GITHUB_NAME"
printf "  Private:      %s\n" "$PRIVATE"
printf "  HTTPS URL:    %s\n" "$REPO_HTTPS"
printf "  SSH URL:      %s\n" "$REPO_SSH"
echo

if [ "$AUTO_YES" != "yes" ]; then
  printf "Proceed with repo creation? [y/N]: "
  read ans || true
  ans=$(printf '%s' "${ans:-}" | tr '[:upper:]' '[:lower:]')
  if [ "$ans" != "y" ] && [ "$ans" != "yes" ]; then
    echo "Aborted."
    exit 0
  fi
fi

# --------- create local dir + git init ---------
mkdir -p "$DIR_NAME"
cd "$DIR_NAME"
git init -q

# --------- try to create remote ---------
if command -v gh >/dev/null 2>&1; then
  VISIBILITY="--private"
  [ "$PRIVATE" = "no" ] && VISIBILITY="--public"
  gh repo create "${GITHUB_NAME}/${REPO_NAME}" $VISIBILITY --source=. --remote=origin --push || {
    echo "gh repo create failed; check credentials."
    exit 1
  }
  echo "Remote repo created: $REPO_HTTPS"
else
  echo "GitHub CLI not found."
  echo "Create the repo manually at: $REPO_HTTPS"
  git remote add origin "$REPO_SSH"
  echo "Then push with:"
  echo "  git push -u origin HEAD"
fi
