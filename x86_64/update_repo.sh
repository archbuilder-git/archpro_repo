#!/bin/bash
set -euo pipefail

KEYID="DFB61E9697C6C104"

cd "$(dirname "$0")"

REPONAME="${1:-}"

detect_repo_name() {
  shopt -s nullglob

  # 1) Kui kaustas on täpselt üks *.db (mitte .tar.gz), kasuta seda
  local dbs=( *.db )
  if (( ${#dbs[@]} == 1 )); then
    echo "${dbs[0]%.db}"
    return 0
  fi

  # 2) Proovi tuvastada git repo juurkataloogi nimest
  local top
  top="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -n "$top" ]]; then
    local base
    base="$(basename "$top")"
    if [[ "$base" == "archpro_repo" || "$base" == "archpro-repo" || "$base" == "archpro-repo-extra" || "$base" == "archpro-xxl" ]]; then
      echo "$base"
      return 0
    fi
  fi

  # 3) Viimane variant: kui leidub varasemaid faile (sig või files)
  if ls archpro_repo.{db,files,db.sig,files.sig} >/dev/null 2>&1; then
    echo "archpro_repo"
    return 0
  fi
  if ls archpro-repo.{db,files,db.sig,files.sig} >/dev/null 2>&1; then
    echo "archpro-repo"
    return 0
  fi

  # 4) fallback: praeguse kausta nimi
  echo "$(basename "$(pwd)")"
}

if [[ -z "$REPONAME" ]]; then
  REPONAME="$(detect_repo_name)"
fi

# sanity: peab olema vähemalt üks pkg
shopt -s nullglob
pkgs=( *.pkg.tar.zst )
if (( ${#pkgs[@]} == 0 )); then
  echo "No *.pkg.tar.zst files found in $(pwd)"
  exit 1
fi

export GPG_TTY="$(tty)"
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true

echo "==> repo-add for: $REPONAME"
rm -f "${REPONAME}.db"* "${REPONAME}.files"*

# -s = sign, -k = key, -n/-R = hoiab pakettide järjekorra/vanad kirjed
repo-add -s -k "$KEYID" -n -R "${REPONAME}.db.tar.gz" "${pkgs[@]}"

mv -f "${REPONAME}.db.tar.gz"     "${REPONAME}.db"
mv -f "${REPONAME}.db.tar.gz.sig" "${REPONAME}.db.sig"
mv -f "${REPONAME}.files.tar.gz"     "${REPONAME}.files"
mv -f "${REPONAME}.files.tar.gz.sig" "${REPONAME}.files.sig"

# (soovi korral) ekspordi public key repo kausta
gpg --armor --export "$KEYID" > archpro.gpg

echo "####################################"
echo "Repo Updated: $REPONAME"
echo "####################################"
