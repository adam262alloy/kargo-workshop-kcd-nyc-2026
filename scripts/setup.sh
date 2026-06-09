#!/usr/bin/env bash
#
# Participant setup for the Kargo guestbook workshop.
#
# Run this AFTER you have forked the repo on GitHub and cloned your fork
# locally. It performs the workshop prerequisites for you:
#
#   1. Points every manifest at your fork / your ghcr.io image and sets the
#      Terraform `participant` to your handle, then commits and pushes to main
#      (which triggers the GitHub Actions image build).
#   2. (Manual) Reminds you to install the Argo CD + Kargo agents from the
#      Akuity dashboard — that step can only be done in the UI.
#   3. Logs in to Argo CD and Kargo (if you pass --argocd-host / --kargo-host).
#   4. Applies the Argo CD AppProject + ApplicationSet.
#   5. Creates the `guestbook` Kargo project.
#   6. Creates the Kargo project secrets (prompts for each credential).
#
# Everything is idempotent and each section can be skipped — see --help.
#
set -euo pipefail

# --- Defaults -----------------------------------------------------------------

# The owner/repo that the manifests currently point at. The script rewrites
# these to your fork.
OLD_OWNER="akuity"
OLD_REPO="kargo-workshop-kcd-nyc-2026"

PROJECT="guestbook"
KARGO="${KARGO:-kargo}"
ARGOCD="${ARGOCD:-argocd}"

OWNER=""
REPO=""
PARTICIPANT=""
ARGOCD_HOST=""
KARGO_HOST=""
KARGO_PASSWORD=""
ARGOCD_PASSWORD=""

DO_MANIFESTS=1
DO_PUSH=1
DO_LOGIN=1
DO_ARGOCD=1
DO_PROJECT=1
DO_SECRETS=1

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- Helpers ------------------------------------------------------------------

info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33mWARNING:\033[0m %s\n' "$*" >&2; }
err()   { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; }
die()   { err "$@"; exit 1; }

usage() {
  cat <<'EOF'
Usage: scripts/setup.sh [options]

Identity (auto-detected from your `origin` git remote if omitted):
  --owner <handle>        Your GitHub username/org (the fork owner)
  --repo <name>           Your fork's repository name
  --participant <handle>  Terraform `participant` value (defaults to --owner)

Logins (skipped unless a host is given; assumes you are already logged in):
  --argocd-host <host>    Run `argocd login <host>`
  --kargo-host <url>      Run `kargo login <url> --admin`

Skip individual sections:
  --skip-manifests        Don't rewrite manifests
  --skip-push             Rewrite manifests but don't commit/push
  --skip-login            Don't run argocd/kargo login
  --skip-argocd           Don't apply the Argo CD AppProject/ApplicationSet
  --skip-project          Don't create the Kargo project
  --skip-secrets          Don't create the Kargo project secrets

  -h, --help              Show this help
EOF
}

# --- Argument parsing ---------------------------------------------------------

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner)        OWNER="$2"; shift 2 ;;
    --repo)         REPO="$2"; shift 2 ;;
    --participant)  PARTICIPANT="$2"; shift 2 ;;
    --argocd-host)  ARGOCD_HOST="$2"; shift 2 ;;
    --kargo-host)   KARGO_HOST="$2"; shift 2 ;;
    --skip-manifests) DO_MANIFESTS=0; shift ;;
    --skip-push)    DO_PUSH=0; shift ;;
    --skip-login)   DO_LOGIN=0; shift ;;
    --skip-argocd)  DO_ARGOCD=0; shift ;;
    --skip-project) DO_PROJECT=0; shift ;;
    --skip-secrets) DO_SECRETS=0; shift ;;
    -h|--help)      usage; exit 0 ;;
    *) die "Unknown argument: $1 (try --help)" ;;
  esac
done

cd "$REPO_ROOT"

# --- Detect fork identity from the git remote ---------------------------------

# Parse owner/repo out of the `origin` URL (handles both SSH and HTTPS forms).
detect_identity() {
  local url
  url="$(git remote get-url origin 2>/dev/null || true)"
  [[ -n "$url" ]] || return 0
  # Strip everything up to and including the host, the leading ':' or '/' that
  # follows it, and the trailing '.git', leaving <owner>/<repo>.
  local path="${url##*github.com}"
  path="${path#:}"
  path="${path#/}"
  path="${path%.git}"
  local detected_owner="${path%%/*}"
  local detected_repo="${path##*/}"
  [[ -z "$OWNER" && -n "$detected_owner" ]] && OWNER="$detected_owner"
  [[ -z "$REPO"  && -n "$detected_repo"  ]] && REPO="$detected_repo"
}

detect_identity
[[ -n "$OWNER" ]] || die "Could not determine your GitHub owner. Pass --owner <handle>."
[[ -n "$REPO"  ]] || REPO="$OLD_REPO"
[[ -n "$PARTICIPANT" ]] || PARTICIPANT="$OWNER"

if [[ "$OWNER" == "$OLD_OWNER" && "$REPO" == "$OLD_REPO" ]]; then
  warn "Your remote still points at ${OLD_OWNER}/${OLD_REPO} — make sure you forked"
  warn "the repo and cloned YOUR fork, otherwise pushes and image builds will fail."
fi

info "Fork owner:   $OWNER"
info "Fork repo:    $REPO"
info "Participant:  $PARTICIPANT"
echo

# --- 1. Point manifests at your fork ------------------------------------------

rewrite_manifests() {
  info "Rewriting manifests to point at ${OWNER}/${REPO} ..."
  # Combined owner/repo in image + git URLs (warehouse/stages/appset/chart).
  grep -rl "${OLD_OWNER}/${OLD_REPO}" \
      --include='*.yaml' --include='*.yml' . \
    | while IFS= read -r f; do
        perl -pi -e "s{\Q${OLD_OWNER}/${OLD_REPO}\E}{${OWNER}/${REPO}}g" "$f"
        echo "  updated $f"
      done

  # Terraform `participant` handle.
  grep -rl "participant *= *\"${OLD_OWNER}\"" \
      --include='*.tfvars' . \
    | while IFS= read -r f; do
        perl -pi -e "s{participant(\s*)=(\s*)\"${OLD_OWNER}\"}{participant\${1}=\${2}\"${PARTICIPANT}\"}g" "$f"
        echo "  updated $f"
      done
}

commit_and_push() {
  if git diff --quiet; then
    info "No manifest changes to commit (already pointed at your fork)."
    return 0
  fi
  info "Committing and pushing manifest changes ..."
  git add -A
  git commit -m "chore: point manifests at ${OWNER}/${REPO}"
  # Push to main so GitHub Actions builds your ghcr.io image.
  local branch
  branch="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "$branch" == "HEAD" ]]; then
    warn "Detached HEAD — pushing to main explicitly."
    git push origin HEAD:main
  else
    git push origin "$branch"
  fi
  info "Pushed. GitHub Actions will now build ghcr.io/${OWNER}/${REPO}."
  warn "After the build finishes, make the package PUBLIC:"
  warn "  https://github.com/users/${OWNER}/packages/container/${REPO}/settings"
}

if [[ "$DO_MANIFESTS" == 1 ]]; then
  rewrite_manifests
  [[ "$DO_PUSH" == 1 ]] && commit_and_push
  echo
fi

# --- 2. Log in to Argo CD and Kargo -------------------------------------------

if [[ "$DO_LOGIN" == 1 ]]; then
  if [[ -n "$ARGOCD_HOST" ]]; then
    info "Logging in to Argo CD ($ARGOCD_HOST) ..."
    "$ARGOCD" login "$ARGOCD_HOST"
  fi
  if [[ -n "$KARGO_HOST" ]]; then
    info "Logging in to Kargo ($KARGO_HOST) ..."
    "$KARGO" login "https://${KARGO_HOST}" --admin
  fi
  if [[ -z "$ARGOCD_HOST" && -z "$KARGO_HOST" ]]; then
    info "Skipping login (no --argocd-host/--kargo-host given); assuming you are"
    info "already logged in to both CLIs."
  fi
  echo
fi

# --- 3. Apply the Argo CD resources -------------------------------------------

if [[ "$DO_ARGOCD" == 1 ]]; then
  if command -v "$ARGOCD" >/dev/null 2>&1; then
    info "Applying Argo CD AppProject + ApplicationSet ..."
    "$ARGOCD" proj create "$PROJECT" -f argocd/appproject.yaml --upsert
    "$ARGOCD" appset create argocd/application-set.yaml --upsert
  else
    warn "argocd CLI not found; skipping. Apply argocd/ from the UI, or install"
    warn "the CLI: https://argo-cd.readthedocs.io/en/latest/cli_installation/"
  fi
  echo
fi

# --- 4. Create the Kargo project ----------------------------------------------

if [[ "$DO_PROJECT" == 1 ]]; then
  if command -v "$KARGO" >/dev/null 2>&1; then
    info "Creating Kargo project '$PROJECT' ..."
    if "$KARGO" get project "$PROJECT" >/dev/null 2>&1; then
      info "Project '$PROJECT' already exists; skipping."
    else
      "$KARGO" create project "$PROJECT"
    fi
  else
    warn "kargo CLI not found; skipping. Create the project from the UI, or"
    warn "install the CLI: https://docs.kargo.io/user-guide/installing-the-cli"
  fi
  echo
fi

# --- 5. Create the Kargo project secrets --------------------------------------

# Prompt for a value, hiding input. Returns empty if the user just hits enter.
prompt_secret() {
  local var="$1" label="$2" value
  read -r -s -p "  $label (enter to skip): " value
  echo
  printf -v "$var" '%s' "$value"
}
prompt_value() {
  local var="$1" label="$2" value
  read -r -p "  $label (enter to skip): " value
  printf -v "$var" '%s' "$value"
}

create_secrets() {
  if ! command -v "$KARGO" >/dev/null 2>&1; then
    warn "kargo CLI not found; skipping secret creation. Create the secrets from the UI"
    return 0
  fi

  info "Creating Kargo project secrets. Leave any prompt blank to skip it."
  echo

  # Git write credentials (so Kargo can push promotion commits to your fork).
  echo "Git credentials (PAT with 'repo' scope so Kargo can push promotions):"
  local git_user git_token
  prompt_value  git_user  "GitHub username [$OWNER]"
  [[ -z "$git_user" ]] && git_user="$OWNER"
  prompt_secret git_token "GitHub token (PAT)"
  if [[ -n "$git_token" ]]; then
    "$KARGO" create repo-credentials --project "$PROJECT" git-creds --git \
      --repo-url "https://github.com/${OWNER}/${REPO}.git" \
      --username "$git_user" --password "$git_token" -o name
    info "Created git-creds."
  else
    info "Skipped git-creds."
  fi
  unset git_token
  echo

  # SMTP credentials for send-message + notifications.
  echo "SMTP credentials (e.g. a Gmail app password):"
  local smtp_user smtp_pass
  prompt_value  smtp_user "SMTP username"
  prompt_secret smtp_pass "SMTP password / app password"
  if [[ -n "$smtp_user" && -n "$smtp_pass" ]]; then
    "$KARGO" create generic-credentials --project "$PROJECT" smtp-credentials \
      --set "username=${smtp_user}" --set "password=${smtp_pass}" -o name
    info "Created smtp-credentials."
  else
    info "Skipped smtp-credentials."
  fi
  unset smtp_pass
  echo

  # ServiceNow credentials for the prod change-request gate.
  echo "ServiceNow credentials (provided during the workshop):"
  local snow_token snow_url
  prompt_secret snow_token "ServiceNow API token"
  prompt_value  snow_url   "ServiceNow instance URL (https://<instance>.service-now.com)"
  if [[ -n "$snow_token" && -n "$snow_url" ]]; then
    "$KARGO" create generic-credentials --project "$PROJECT" kargo-step-snow \
      --set "apiToken=${snow_token}" --set "instanceURL=${snow_url}" -o name
    info "Created kargo-step-snow."
  else
    info "Skipped kargo-step-snow."
  fi
  unset snow_token
  echo

  # AWS credentials for the Lambda/Terraform steps.
  echo "AWS credentials (provided during the workshop):"
  local aws_key aws_secret
  prompt_value  aws_key    "AWS_ACCESS_KEY_ID"
  prompt_secret aws_secret "AWS_SECRET_ACCESS_KEY"
  if [[ -n "$aws_key" && -n "$aws_secret" ]]; then
    "$KARGO" create generic-credentials --project "$PROJECT" aws-creds \
      --set "AWS_ACCESS_KEY_ID=${aws_key}" \
      --set "AWS_SECRET_ACCESS_KEY=${aws_secret}" -o name
    info "Created aws-creds."
  else
    info "Skipped aws-creds."
  fi
  unset aws_secret
  echo
}

if [[ "$DO_SECRETS" == 1 ]]; then
  create_secrets
fi

info "Setup complete. You're ready to start the workshop steps."
