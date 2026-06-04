#!/bin/sh
# Install the joblisting CLI by downloading the right prebuilt binary from GitHub Releases.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/michaelbonner/joblisting-cli/main/install.sh | sh
#
# Env overrides:
#   JOBLISTING_INSTALL_DIR   install location (default: /usr/local/bin, or ~/.local/bin if not writable)
#   JOBLISTING_VERSION       release tag to install (default: latest)
#
# This file is the source of truth; cli-release.yml mirrors it (and the prebuilt
# binaries) to the public michaelbonner/joblisting-cli repo, which is where users
# install from. The app repo itself is private, so its release/raw URLs 404 for
# anonymous downloads.
#
# POSIX sh compatible (the README pipes this to `sh`, which may be dash): no
# pipefail or other bashisms. There are no pipelines here, so `set -eu` suffices.
set -eu

REPO="michaelbonner/joblisting-cli"
BIN_NAME="joblisting"

err() { echo "error: $*" >&2; exit 1; }

# --- detect platform ---
os="$(uname -s)"
arch="$(uname -m)"
case "$os" in
	Darwin) os_part="macos" ;;
	Linux)  os_part="linux" ;;
	*) err "unsupported OS: $os (Windows users: download joblisting-windows-x64.exe from the releases page)" ;;
esac
case "$arch" in
	arm64|aarch64) arch_part="arm64" ;;
	x86_64|amd64)  arch_part="x64" ;;
	*) err "unsupported architecture: $arch" ;;
esac

# Linux only ships an x64 build today.
if [ "$os_part" = "linux" ] && [ "$arch_part" = "arm64" ]; then
	err "no prebuilt linux-arm64 binary is published yet"
fi

asset="${BIN_NAME}-${os_part}-${arch_part}"

# --- resolve version/tag ---
version="${JOBLISTING_VERSION:-latest}"
if [ "$version" = "latest" ]; then
	url="https://github.com/${REPO}/releases/latest/download/${asset}"
else
	url="https://github.com/${REPO}/releases/download/${version}/${asset}"
fi

# --- pick install dir ---
install_dir="${JOBLISTING_INSTALL_DIR:-/usr/local/bin}"
if [ ! -d "$install_dir" ] || [ ! -w "$install_dir" ]; then
	install_dir="$HOME/.local/bin"
	mkdir -p "$install_dir"
fi
dest="${install_dir}/${BIN_NAME}"

echo "Downloading ${asset} → ${dest}"
if command -v curl >/dev/null 2>&1; then
	curl -fSL "$url" -o "$dest"
elif command -v wget >/dev/null 2>&1; then
	wget -O "$dest" "$url"
else
	err "need curl or wget to download"
fi

chmod +x "$dest"

echo "Installed joblisting to $dest"
case ":$PATH:" in
	*":$install_dir:"*) ;;
	*) echo "note: $install_dir is not on your PATH — add it to use 'joblisting' directly." ;;
esac
echo "Run 'joblisting login' to get started."
