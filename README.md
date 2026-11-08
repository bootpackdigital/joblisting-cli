# joblisting CLI

Prebuilt binaries and the install script for the **joblisting** command-line tool — a
standalone way to manage your job-listing data (listings, candidate submissions,
organization settings, members, invitations, and API tokens). It talks to your
deployment's `/api/v1` HTTP API using an organization API token, so it works against any
environment (local, staging, production).

> This repo only hosts the installer and the compiled binaries. The application source
> lives in a separate private repository; releases here are published automatically by its
> CI when a `cli-v*` tag is cut.

## Install

### One-line installer (macOS / Linux)

```sh
curl -fsSL https://raw.githubusercontent.com/bootpackdigital/joblisting-cli/main/install.sh | sh
```

This downloads the right native binary for your platform from the
[latest release](https://github.com/bootpackdigital/joblisting-cli/releases/latest) and
drops it on your `PATH`.

Environment overrides:

- `JOBLISTING_INSTALL_DIR` — install location (default `/usr/local/bin`, or `~/.local/bin`
  if that isn't writable)
- `JOBLISTING_VERSION` — release tag to install (default `latest`)

### Manual download

Grab the binary for your platform from the
[latest release](https://github.com/bootpackdigital/joblisting-cli/releases/latest) and make
it executable:

| Platform      | Asset                        |
| ------------- | ---------------------------- |
| macOS (Apple) | `joblisting-macos-arm64`     |
| macOS (Intel) | `joblisting-macos-x64`       |
| Linux (x64)   | `joblisting-linux-x64`       |
| Windows (x64) | `joblisting-windows-x64.exe` |

```sh
chmod +x joblisting-macos-arm64
sudo mv joblisting-macos-arm64 /usr/local/bin/joblisting
```

Verify your download against `SHA256SUMS.txt` from the release:

```sh
shasum -a 256 -c SHA256SUMS.txt --ignore-missing
```

> The CLI ships as a self-contained native binary — no Node.js or Bun runtime required.
> It is **not** published to npm.

## Authentication

The CLI authenticates with an **organization API token**. Create one in the app under
**Settings → API tokens**, then log in:

```sh
joblisting login --api-url https://jobs.example.com --token jl_xxxxxxxx…
```

Credentials are saved to `~/.config/joblisting/config.json` (mode `600`). You can also
provide them per-invocation via flags (`--api-url`, `--token`) or environment variables
(`JOBLISTING_API_URL`, `JOBLISTING_TOKEN`). Precedence is **flags → environment → config
file**.

```sh
joblisting whoami     # confirm which organization the token belongs to
joblisting config     # show current configuration (token masked)
joblisting logout     # forget the saved token
```

Tokens are scoped to a single organization. Organization-management commands
(`org update`, `org members remove`, `org invitations …`, `org tokens …`) additionally
require that the token was created by an owner/admin.

## Commands

Add `--json` to any command for raw JSON output (handy for scripting).

```sh
joblisting listings   list | get | create | update | delete
joblisting submissions list | get | move | comment | tag | archive | unarchive
joblisting stages                 # pipeline stages
joblisting tags                   # organization tags
joblisting org        show | update | members | invitations | tokens
```

Run `joblisting <command> --help` for the full options on any command.
