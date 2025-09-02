#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG (muuda kui vaja) ---
BUILDER_NAME="ArchPro"
EMAIL_GITHUB="189096068+archbuilder-git@users.noreply.github.com"
EMAIL_GITLAB_ARCHBUILDER="archbuilder@gitlab.local"
EMAIL_GITLAB_ARCHPRO="archpro@gitlab.local"
EMAIL_GITLAB_ISO="archbuilder-iso@gitlab.local"

# --- SAFETY ---
if [[ $EUID -eq 0 ]]; then
  echo "Do not run this script as root." >&2
  exit 1
fi
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a Git repository." >&2
  exit 1
fi

# --- REMOTE (must be SSH) ---
remote_url="$(git remote get-url origin 2>/dev/null || true)"
if [[ -z "$remote_url" ]]; then
  echo "No 'origin' remote set. Use SSH, e.g. git@<alias>:<namespace>/<repo>.git" >&2
  exit 1
fi
if [[ "$remote_url" =~ ^https:// ]]; then
  cat >&2 <<EOF
################################################################
ERROR: origin is HTTPS → $remote_url
Switch to SSH before using this script, e.g.:
  git remote set-url origin git@<alias>:<namespace>/<repo>.git
Aliases (per ~/.ssh/config):
  - gitlab-archbuilder, gitlab-archpro, gitlab-archbuilder-iso
  - github.com (or github-archbuilder)
################################################################
EOF
  exit 1
fi

# --- Parse SSH remote into host alias + path ---
# Examples:
#   git@gitlab-archpro:archpro/archpro-xxl.git
#   git@github.com:archbuilder-git/some-repo.git
host_alias="" ; ns_repo=""
if [[ "$remote_url" =~ ^git@([^:]+):(.+)\.git$ ]]; then
  host_alias="${BASH_REMATCH[1]}"
  ns_repo="${BASH_REMATCH[2]}"  # <namespace>/<repo>
fi

# --- Identity (per host) ---
git config user.name "${BUILDER_NAME}"
case "$host_alias" in
  github.com|github-archbuilder)
    git config user.email "${EMAIL_GITHUB}"
    ;;
  gitlab-archbuilder)
    git config user.email "${EMAIL_GITLAB_ARCHBUILDER}"
    ;;
  gitlab-archpro)
    git config user.email "${EMAIL_GITLAB_ARCHPRO}"
    ;;
  gitlab-archbuilder-iso)
    git config user.email "${EMAIL_GITLAB_ISO}"
    ;;
  *)
    git config user.email "builder@example.com"
    ;;
esac

# --- SSH key (per host) ---
case "$host_alias" in
  gitlab-archpro )
    export GIT_SSH_COMMAND="ssh -o IdentitiesOnly=yes -i $HOME/.ssh/id_ed25519_gitlab_archpro"
    ;;
  gitlab-archbuilder|gitlab-archbuilder-iso|github.com|github-archbuilder )
    export GIT_SSH_COMMAND="ssh -o IdentitiesOnly=yes -i $HOME/.ssh/id_ed25519"
    ;;
  * )
    export GIT_SSH_COMMAND="ssh -o IdentitiesOnly=yes"
    ;;
esac

# --- LFS FIX: HTTPS endpoint on real domain (not SSH alias) ---
if command -v git-lfs >/dev/null 2>&1; then
  lfs_url=""
  case "$host_alias" in
    github.com|github-archbuilder)
      # GitHub LFS endpoint
      lfs_url="https://github.com/${ns_repo}.git/info/lfs"
      ;;
    gitlab-archbuilder|gitlab-archpro|gitlab-archbuilder-iso)
      # GitLab LFS endpoint
      lfs_url="https://gitlab.com/${ns_repo}.git/info/lfs"
      ;;
    *)
      lfs_url=""
      ;;
  esac

  # Remove any bad alias-based HTTPS LFS keys (e.g., https://gitlab-archpro/...)
  # and any leftover mismatched alias hosts.
  while IFS='=' read -r key _; do
    [[ -n "$key" ]] && git config --unset-all "$key" || true
  done < <(git config -l | grep -E '^lfs\.https://gitlab-arch(pro|builder|builder-iso)/')

  if [[ -n "$lfs_url" ]]; then
    # Write both project .lfsconfig and local git config
    git config -f .lfsconfig lfs.url "${lfs_url}"
    git config -f .lfsconfig lfs.locksverify false
    git add .lfsconfig || true

    git config lfs.url "${lfs_url}"
    git config lfs.locksverify false
  fi

  # Heads-up if LFS auth missing (informational; ei katkesta)
  if git lfs env | grep -qi 'Endpoint=.*auth=none'; then
    cat >&2 <<'EOF'
[NOTE] Git LFS shows auth=none.
      If push asks for credentials, add a GitLab/GitHub Personal Access Token:
      - ~/.netrc:   machine gitlab.com login oauth2 password <PAT>
      - or git credential store:
          git config --global credential.helper store
          git credential approve <<EOF2
          protocol=https
          host=gitlab.com
          username=oauth2
          password=<PAT>
          EOF2
EOF
  fi
fi

# --- Run repo update if present ---
if [[ -x ./x86_64/update_repo.sh ]]; then
  echo "Updating repo database..."
  (cd x86_64 && ./update_repo.sh)
fi

# --- Git LFS track (idempotent) ---
if command -v git-lfs >/dev/null 2>&1; then
  git lfs install --skip-repo || true
  git lfs track "*.pkg.tar.zst" "*.pkg.tar.zst.sig" || true
  git add .gitattributes || true
fi

# --- Stage, commit, rebase & push ---
git add -A
if git diff --staged --quiet; then
  echo "No changes to commit."
else
  git commit -m "Auto-update repository and signatures"
fi

git pull --rebase || echo "Warning: could not rebase, continuing..."
git push -u origin main

echo "################################################################"
echo "###################    Git Push Done      ######################"
echo "################################################################"
