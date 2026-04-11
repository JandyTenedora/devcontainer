# Claude Code Devcontainer

Runs Claude Code in an isolated Docker container with access only to the repo it's placed in. Designed for security when repo-hopping.

## What has access to what

| Resource | Inside container | Notes |
|---|---|---|
| Repo files | Yes (read/write) | The repo root is mounted at `/workspace` |
| `~/.claude` | Yes | Auth tokens — needed for Claude Code to function |
| `~/.gitconfig` | Yes (readonly) | Name, email, aliases |
| `~/.ssh` | No | Keys never enter the container |
| Rest of host filesystem | No | |

Git authentication uses a scoped PAT via `GIT_ASKPASS` — the token is injected at runtime and never written to disk inside the container.

---

## One-time setup

### 1. Authenticate Claude Code on your host

Do this once, outside any container. The token is saved to `~/.claude` on your host and picked up automatically by every container via the mount.

```sh
npm install -g @anthropic-ai/claude-code
claude
```

The browser opens normally on macOS and you complete the OAuth flow. You can uninstall Claude Code from the host afterwards — the token file stays.

If the token ever expires, repeat this step.

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

```sh
export GIT_TOKEN=github_pat_xxxx
```

### 2. Run

From the project root:

```sh
./.devcontainer/start-claude
```

The container builds on first run. Subsequent runs are instant. Claude Code starts immediately.

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
