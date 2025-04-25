#!/bin/bash

echo "🔐 Verifying GPG signatures for all repository files..."

# Change to x86_64 directory if needed
cd "$(dirname "$0")"

# List of file types to check
files_to_verify=(
  "*.pkg.tar.zst"
  "archpro-repo.db"
  "archpro-repo.files"
)

for base in "${files_to_verify[@]}"; do
  for file in $base; do
    sig="${file}.sig"
    if [[ -f "$sig" ]]; then
      echo "🔍 Verifying: $file"
      gpg --verify "$sig" "$file" || {
        echo "❌ Verification failed for $file"
        exit 1
      }
    else
      echo "⚠️  Missing signature for $file"
    fi
  done
done

echo "✅ All signatures verified successfully."
