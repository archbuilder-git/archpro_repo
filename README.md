# ArchPro Repo (GitHub Pages)

This is a custom Arch Linux repository hosted on **GitHub Pages**, maintained by **ArchBuilder**. It provides signed packages built and packaged with care for personal and community use.

---

## 🔐 Add GPG Key

To enable package signature verification, first download and trust the signing key:

```bash
curl -O https://archbuilder-git.github.io/archpro_repo/x86_64/archpro.gpg
sudo pacman-key --add archpro.gpg
sudo pacman-key --lsign-key DFB61E9697C6C104
```

---

## 📦 Add the Repository to pacman.conf

Edit your `/etc/pacman.conf` and add the following:

```ini
[archpro_repo]
SigLevel = Optional TrustedOnly
Server = https://archbuilder-git.github.io/$repo/$arch
```

Then sync the package database:

```bash
sudo pacman -Sy
```

---

## 🛡 Package Integrity

All packages and the database are signed using:

- **GPG Key ID**: `DFB61E9697C6C104`
- **Maintainer**: Jyri Luik <archpro83@gmail.com>

You may verify package signatures manually with:

```bash
gpg --verify package.pkg.tar.zst.sig
```

---

## 📌 Notes

- You can optionally change `SigLevel` to `Required` for strict signature checking.
- This GitHub-hosted version of the repo is suitable for pacman-based systems with HTTPS access.
- The repo structure is compatible with `$repo` and `$arch` substitution in `pacman.conf`.

---

## 🔄 Updating

This repo is auto-updated using scripts that:
- Regenerate the `.db` and `.files` databases
- Sign all relevant files
- Export and include the GPG public key
- Push changes to the GitHub repo

