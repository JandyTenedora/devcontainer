# Claude Code Devcontainer

Runs Claude Code in an isolated Docker container with access only to the repo it's placed in. Designed for security when repo-hopping.

## What has access to what

| Resource | Inside container | Notes |
|---|---|---|
| Repo files | Yes (read/write) | The repo root is mounted at `/workspace` |
| `~/.claude` | Yes | Claude Code state — history, sessions, settings |
| `~/.claude.json` | Yes | Claude Code config file |
| `~/.claude_oauth` | Yes | OAuth token — needed for auth |
| `~/.gitconfig` | Yes (readonly) | Name, email, aliases |
| `~/.ssh` | No | Keys never enter the container |
| Rest of host filesystem | No | |

Git authentication uses a scoped PAT via `GIT_ASKPASS` — the token is injected at runtime and never written to disk inside the container.

---

## One-time setup

### 1. Get your Claude Code OAuth token

Claude Code → Settings → get your long-lived OAuth token. Add it to `~/.zshrc` so it's available in every session without re-exporting:

```sh
echo 'export CLAUDE_CODE_OAUTH_TOKEN=your-token-here' >> ~/.zshrc
```

### 2. Create a GitHub fine-grained PAT

GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new token.

Recommended scope per repo:
- **Repository access**: only the repo you're working in
- **Permissions**: Contents (Read & Write), Metadata (Read)

Store it in a password manager.

---

## Adding to a new repo

`.devcontainer` is local-only — it should never be committed or pushed to the project repo.

From the root of the target repo:

```sh
echo '.devcontainer' >> .gitignore
git clone git@github.com:JandyTenedora/devcontainer.git .devcontainer
```

The cloned directory has its own `.git`, so the parent repo won't track it. The `.gitignore` entry keeps it out of `git status` noise.

To pull updates in the future:

```sh
git -C .devcontainer pull
```

---

## Per-session workflow

### 1. Export your PAT

`CLAUDE_CODE_OAUTH_TOKEN` is long-lived — set it once in `~/.zshrc` (see one-time setup). For the PAT, export a fresh one each session:

```sh
export GIT_TOKEN=github_pat_xxxx
```

### 2. Run

From the project root:

```sh
./.devcontainer/start-claude
```

Uses the existing image — fast. After pulling devcontainer updates, rebuild the image first:

```sh
./.devcontainer/start-claude-rebuild
```

If you need a shell instead:

```sh
docker compose -f .devcontainer/docker-compose.yml run --rm claude sh
```

### 3. When done

Revoke the PAT on GitHub — Settings → Developer settings → Personal access tokens → Revoke.

Generate a fresh one next session.

---

## How git authentication works

The container has no SSH keys. Instead, `GIT_ASKPASS` is set to a small script that returns your `GIT_TOKEN` when git asks for credentials. The token is only in memory — it is never written to any file inside the container.

## Note on Alpine

This image uses `node:lts-alpine` (musl libc). Claude Code is pure JavaScript so this should be fine, but if you hit unexpected errors swap `FROM node:lts-alpine` for `FROM node:lts-slim` in the Dockerfile.
