#!/bin/bash
set -euo pipefail

# ========================
#   Default configuration
# ========================
CREATE_VENV=true
INIT_GIT=true
CREATE_DJANGO=false
YES_MODE=false
DB_CHOICE=""
DB_NAME=""
DB_USER=""
DB_PASS=""
PROJECT_NAME=""
CURRENT_DIR=$(pwd)

# ========================
#   Functions
# ========================
show_help() {
    echo "Usage: create_project [options] [project_name]"
    echo
    echo "Options:"
    echo "  --no-venv         Ne pas créer d'environnement virtuel"
    echo "  --no-git          Ne pas initialiser de dépôt Git"
    echo "  --django          Créer un projet Django"
    echo "  --db <type>       Base de données (sqlite, postgres, mysql)"
    echo "  --db-name <name>  Nom de la base de données"
    echo "  --db-user <user>  Utilisateur DB"
    echo "  --db-pass <pass>  Mot de passe DB"
    echo "  --yes             Mode non interactif (choix par défaut)"
    echo "  --help            Affiche cette aide"
    exit 0
}

generate_secret_key() {
    $PYTHON_CMD - <<'EOF'
import secrets
print(secrets.token_urlsafe(50))
EOF
}

check_dependencies() {
    for cmd in git; do
        if ! command -v $cmd &>/dev/null; then
            echo "❌ Erreur : $cmd est requis mais non installé."
            exit 1
        fi
    done
}

detect_python() {
    if command -v python3 &>/dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &>/dev/null; then
        PYTHON_CMD="python"
    else
        echo "❌ Erreur : Python n'est pas installé ni accessible dans le PATH."
        echo "➡️ Installe Python depuis https://www.python.org/downloads/"
        exit 1
    fi
}

create_structure_generic() {
    mkdir -p src/"$1"
    mkdir -p tests docs
    touch src/"$1"/__init__.py
}

create_env_file() {
    local secret_key
    secret_key=$(generate_secret_key)

    cat <<EOF > .env
DEBUG=True
SECRET_KEY=$secret_key
DATABASE_URL=$DB_URL
EOF

    cat <<EOF > .env.example
DEBUG=True
SECRET_KEY=changeme!
DATABASE_URL=$DB_URL
EOF
}

setup_database() {
    local default_db="${PROJECT_NAME}_db"

    if [[ -z "$DB_CHOICE" ]]; then
        if ! $YES_MODE; then
            echo
            echo "🔧 Choisis une base de données :"
            echo "1) SQLite (par défaut)"
            echo "2) PostgreSQL"
            echo "3) MySQL / MariaDB"
            read -rp "Ton choix [1-3] : " choice
        else
            choice=1
        fi
    else
        case "$DB_CHOICE" in
            sqlite) choice=1 ;;
            postgres) choice=2 ;;
            mysql) choice=3 ;;
            *) echo "❌ DB inconnue: $DB_CHOICE"; exit 1 ;;
        esac
    fi

    case "$choice" in
        2)
            DB_NAME=${DB_NAME:-$default_db}
            DB_USER=${DB_USER:-postgres}
            DB_PASS=${DB_PASS:-password}
            DB_URL="postgres://${DB_USER}:${DB_PASS}@localhost:5432/${DB_NAME}"
            ;;
        3)
            DB_NAME=${DB_NAME:-$default_db}
            DB_USER=${DB_USER:-root}
            DB_PASS=${DB_PASS:-password}
            DB_URL="mysql://${DB_USER}:${DB_PASS}@localhost:3306/${DB_NAME}"
            ;;
        *)
            DB_URL="sqlite:///db.sqlite3"
            ;;
    esac
}

create_makefile() {
    cat <<'EOF' > Makefile
setup:
	$(PYTHON_CMD) -m venv .venv
	.venv/bin/pip install --upgrade pip
	.venv/bin/pip install -r requirements.txt

run:
	.venv/bin/python src/manage.py runserver

migrate:
	.venv/bin/python src/manage.py migrate

createsuperuser:
	.venv/bin/python src/manage.py createsuperuser

test:
	.venv/bin/python -m unittest discover tests

freeze:
	.venv/bin/pip freeze > requirements.txt

clean:
	rm -rf __pycache__ *.pyc .venv
EOF
}

create_gitignore() {
    cat <<'EOF' > .gitignore
# Python
__pycache__/
*.py[cod]
*.pyo
*.pyd
*.pdb
*.egg-info/
dist/
build/

# venv
.venv/
venv/

# Django
*.log
db.sqlite3
media/

# Env
.env
EOF
}

create_readme() {
    cat <<EOF > README.md
# $PROJECT_NAME

## 🚀 Installation

\`\`\`bash
make setup
\`\`\`

## ▶️ Lancer le serveur

\`\`\`bash
make run
\`\`\`

## ⚙️ Variables d'environnement

Voir fichier \`.env.example\`.

EOF
}

# ========================
#   Parse options
# ========================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-venv) CREATE_VENV=false; shift ;;
        --no-git) INIT_GIT=false; shift ;;
        --django) CREATE_DJANGO=true; shift ;;
        --db) DB_CHOICE=$2; shift 2 ;;
        --db-name) DB_NAME=$2; shift 2 ;;
        --db-user) DB_USER=$2; shift 2 ;;
        --db-pass) DB_PASS=$2; shift 2 ;;
        --yes) YES_MODE=true; shift ;;
        --help) show_help ;;
        *) PROJECT_NAME=$1; shift ;;
    esac
done

# ========================
#   Setup Project
# ========================
detect_python
check_dependencies

if [[ -n "$PROJECT_NAME" ]]; then
    PROJECT_DIR="$CURRENT_DIR/$PROJECT_NAME"
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
else
    PROJECT_DIR="$CURRENT_DIR"
fi

echo "📂 Création du projet dans $PROJECT_DIR"

# Virtualenv
if $CREATE_VENV; then
    $PYTHON_CMD -m venv .venv
    echo "✅ Environnement virtuel créé."
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win"* ]]; then
        source .venv/Scripts/activate
    else
        source .venv/bin/activate
    fi
    pip install --upgrade pip
fi

# Django ou structure générique
if $CREATE_DJANGO; then
    mkdir -p src
    pip install django python-dotenv dj-database-url
    django-admin startproject config src/
    echo "✅ Projet Django initialisé."
else
    create_structure_generic "$PROJECT_NAME"
    echo "✅ Structure Python générique créée."
fi

# Database
setup_database
create_env_file
echo "✅ Fichier .env créé."

# Git
if $INIT_GIT; then
    git init
    create_gitignore
    echo "✅ Dépôt Git initialisé."
fi

# Requirements
cat <<EOF > requirements.txt
Django>=5,<6
python-dotenv
dj-database-url
EOF

# Makefile + README
create_makefile
create_readme

echo "✅ Makefile ajouté."
echo "✅ README.md créé."
echo
echo "🎉 Projet '$PROJECT_NAME' prêt dans $PROJECT_DIR"
