#!/usr/bin/env bash
# Minimal helper to commit & push the current project to GitHub.
# Run from: /Users/tanujsharmaomkar/Desktop/project/pelican
set -e

# Check git
if ! command -v git >/dev/null 2>&1; then
  echo "git is not installed. Install git and retry."
  exit 1
fi

# Ensure we're in the project root (best-effort)
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

echo "Repository path: $REPO_ROOT"
echo
git status --porcelain
echo
git status --short

read -p "Stage all changes and create a commit? (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Aborted by user."
  exit 0
fi

read -p "Commit message: " COMMIT_MSG
COMMIT_MSG="${COMMIT_MSG:-'Update project files'}"

# Default branch
DEFAULT_BRANCH="main"
read -p "Branch to push [${DEFAULT_BRANCH}]: " BRANCH
BRANCH="${BRANCH:-$DEFAULT_BRANCH}"

# Remote handling
HAS_REMOTE="$(git remote | wc -l | tr -d ' ')"
if [[ "$HAS_REMOTE" -eq 0 ]]; then
  echo
  read -p "No git remote found. Enter GitHub repo URL to add as 'origin' (e.g. git@github.com:user/repo.git or https://github.com/user/repo.git): " REMOTE_URL
  if [[ -z "$REMOTE_URL" ]]; then
    echo "No remote provided. Aborting."
    exit 1
  fi
  git remote add origin "$REMOTE_URL"
  echo "Added remote 'origin' -> $REMOTE_URL"
fi

# Ensure branch exists locally
if ! git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
  echo "Creating and switching to branch '$BRANCH'"
  git checkout -b "$BRANCH"
else
  git checkout "$BRANCH"
fi

git add -A
git commit -m "$COMMIT_MSG" || {
  echo "Nothing to commit (or commit failed). Exiting."
  exit 0
}

echo "Pushing to origin/$BRANCH..."
git push -u origin "$BRANCH"
echo "Push complete."
