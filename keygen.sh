#!/usr/bin/env bash
set -e

scriptname="$(basename "$0")"

if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
  cat <<EOF
How to use: $scriptname <domain> [key_name] [username]
<...> - required
[...] - optional

  ʕっ•ᴥ•ʔっ

EOF
  exit 0
fi

host="$1"; name="${2:-$1}"; user="${3:-git}"
key="$HOME/.ssh/$name"

if grep -qiE "^[[:space:]]*Host[[:space:]].*\b${host//./\\.}\b" ~/.ssh/config 2>/dev/null; then
  echo "~/.ssh/config already contains section for $host — remove it or edit manually." >&2
  exit 1
fi

mkdir -p ~/.ssh && chmod 700 ~/.ssh

ssh-keygen -t ed25519 -f "$key" -C "$USER@$name"

keychain=""
[[ "$(uname)" == "Darwin" ]] && keychain=$'\n    UseKeychain yes'

cat >> ~/.ssh/config <<EOF

Host $host
    User $user
    IdentityFile $key
    IdentitiesOnly yes
    AddKeysToAgent yes$keychain
EOF

if command -v pbcopy >/dev/null; then
  pbcopy < "$key.pub"
elif command -v wl-copy >/dev/null; then
  wl-copy < "$key.pub"
elif command -v xclip >/dev/null; then
  xclip -selection clipboard < "$key.pub"
else
  echo "Public key:"; cat "$key.pub"; exit 0
fi
echo "Public key is in the clipboard. If not, copy the output above"