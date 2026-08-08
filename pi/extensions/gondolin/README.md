# Gondolin sandbox for Pi

Runs Pi's built-in tools (`bash`, `read`, `write`, `edit`, `grep`, `find`, and
`ls`) inside a [Gondolin](https://github.com/earendil-works/gondolin) QEMU
micro-VM.

The checked-in extension is application-neutral. Repository names, network
policy, guest environment, credentials, and custom images belong in a local
configuration that is excluded from Git.

## Setup

```sh
npm install --ignore-scripts
mkdir -p .local
cp config.example.json .local/config.json
```

Edit `.local/config.json` for the local machine. Alternatively, keep the file
outside this checkout and set `PI_GONDOLIN_CONFIG` to its path.

Configuration contains a `profiles` array. A profile is selected when an entry
in `repositories` matches either the main checkout's basename or its absolute
path. This also works when Pi starts in a Git worktree. If no profile matches,
Gondolin uses its stock image with no network, SSH, TCP forwarding, or build
cache.

Supported profile fields:

- `imagePath`: path to built Gondolin image assets
- `allowedHttpHosts`: HTTP(S) egress allowlist
- `ssh`: allowed hosts, Git organizations, agent socket, and push policy
- `tcpHosts`: guest hostname to host endpoint mappings
- `env`: guest environment overrides
- `forwardEnv`: names of environment variables to copy from Pi's host
  environment; variables that are not set are ignored
- `buildCache`: enables `/build-cache` and optionally seeds local files
- `memory` and `cpus`: VM resources
- `provisionCommands`: commands run once after guest startup

Relative paths resolve from Pi's working directory. Paths beginning with `~/`
resolve from the user's home directory.

To supply secrets without storing their values in the config, list their names
in `forwardEnv` and inject them when launching Pi. For example, using the
1Password CLI:

```sh
GH_TOKEN=$(op read "op://Private/Github/Token") pi
```

## Custom image

Keep image source and generated assets in an ignored local directory or outside
the dotfiles repository. A typical build is:

```sh
docker build --platform linux/arm64 -t local-dev:latest \
  -f ~/.config/pi/gondolin/image/Dockerfile \
  ~/.config/pi/gondolin/image

node_modules/.bin/gondolin build \
  --config ~/.config/pi/gondolin/image/build-config.json \
  --output ~/.config/pi/gondolin/image/assets
```

Set the resulting assets directory as the profile's `imagePath`. Without it,
the profile uses Gondolin's stock Alpine image.

## Usage

```sh
cd /path/to/project
pi -e ~/dotfiles/pi/extensions/gondolin
```

Requires QEMU and e2fsprogs (`brew install qemu e2fsprogs`). Gondolin currently
declares Node 23.6 or newer but is not engine-strict.

## Isolation notes

- Working trees are mounted read-write at identical guest paths so Git
  worktrees continue to resolve their main checkout.
- Guest build caches are isolated by repository path.
- Seeded credential files are copied into the repository-specific cache; they
  are never added to this extension directory.
- The guest root filesystem is ephemeral.
