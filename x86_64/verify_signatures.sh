#!/bin/bash
set -euo pipefail

echo "🔐 Verifying GPG signatures for repository files..."
cd "$(dirname "$0")"

verify_one() {
  local file="$1"
  local sig="${file}.sig"

  if [[ -f "$sig" ]]; then
    echo "🔍 Verifying: $file"
    gpg --verify "$sig" "$file"
  else
    echo "⚠  Missing signature for $file"
  fi
}

shopt -s nullglob

# 1) Packages
for f in *.pkg.tar.zst; do
  verify_one "$f"
done

# 2) Repo DB + files (supports archpro_repo, archpro-repo, archpro-xxl, jne)
for f in *.db *.files; do
  # välista tar.gz vahefailid, kui keegi jätab need alles
  [[ "$f" == *.tar.gz ]] && continue
  verify_one "$f"
done

echo "✅ Signature verification finished."
