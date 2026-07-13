#!/bin/bash
# lib/git.sh — Opérations Git : init, .gitignore

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/common.sh"

# ========================
#   Initialisation Git
# ========================

# Initialiser un dépôt Git
# Usage: init_git /path/to/project
init_git() {
    local project_dir="${1:-.}"

    if ! command -v git &>/dev/null; then
        msg_warn "Git non détecté — dépôt non initialisé."
        return 0
    fi

    if [[ -d "$project_dir/.git" ]]; then
        msg_warn "Un dépôt Git existe déjà."
        return 0
    fi

    msg_progress "Initialisation du dépôt Git..."
    git -C "$project_dir" init --quiet
    msg_success "Dépôt Git initialisé."
}

# Faire le commit initial
# Usage: git_commit_initial /path/to/project "message"
git_commit_initial() {
    local project_dir="${1:-.}"
    local message="${2:-Initial commit}"

    if [[ ! -d "$project_dir/.git" ]]; then
        msg_warn "Pas de dépôt Git — commit ignoré."
        return 0
    fi

    git -C "$project_dir" add .
    git -C "$project_dir" commit -m "$message" --quiet
    msg_success "Commit initial créé."
}

# ========================
#   .gitignore
# ========================

# Générer un .gitignore pour Python/Django
# Usage: create_gitignore /path/to/project
create_gitignore() {
    local project_dir="${1:-.}"

    cat <<'EOF' > "$project_dir/.gitignore"
# Python
__pycache__/
*.py[cod]
*.pyo
*.pyd
*.pdb
*.egg-info/
dist/
build/
*.egg

# venv
.venv/
venv/
.ENV/

# Django
*.log
db.sqlite3
media/
staticfiles/

# Env
.env
.env.*
!.env.example

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
EOF

    msg_success ".gitignore créé."
}
