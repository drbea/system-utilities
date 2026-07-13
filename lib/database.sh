#!/bin/bash
# lib/database.sh — Configuration des bases de données

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/common.sh"

# Variables globales (remplies par setup_database)
DB_CHOICE=""
DB_NAME=""
DB_USER=""
DB_PASS=""
DB_URL=""

# ========================
#   Configuration
# ========================

# Configurer la base de données (interactif ou non)
# Usage: setup_database "project_name" [--yes] [--db type] [--db-name name] [--db-user user] [--db-pass pass]
setup_database() {
    local project_name="${1:-myproject}"
    local yes_mode=false
    local default_db="${project_name}_db"

    # Parser les options restantes
    shift || true
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --yes) yes_mode=true; shift ;;
            --db) DB_CHOICE="$2"; shift 2 ;;
            --db-name) DB_NAME="$2"; shift 2 ;;
            --db-user) DB_USER="$2"; shift 2 ;;
            --db-pass) DB_PASS="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    # Si choix déjà fourni via flag
    if [[ -n "$DB_CHOICE" ]]; then
        case "$DB_CHOICE" in
            sqlite)   set_sqlite ;;
            postgres) set_postgres "$default_db" ;;
            mysql)    set_mysql "$default_db" ;;
            *) msg_error "Base de données inconnue : $DB_CHOICE"; return 1 ;;
        esac
        return 0
    fi

    # Mode interactif
    if ! $yes_mode; then
        echo
        echo "Base de donnees :"
        echo "  1) SQLite (defaut)"
        echo "  2) PostgreSQL"
        echo "  3) MySQL / MariaDB"
        msg_question "Votre choix [1-3] : "
        read -r choice
    else
        choice=1
    fi

    case "$choice" in
        2) set_postgres "$default_db" ;;
        3) set_mysql "$default_db" ;;
        *) set_sqlite ;;
    esac
}

# ========================
#   Helpers internes
# ========================

set_sqlite() {
    DB_CHOICE="sqlite"
    DB_URL="sqlite:///db.sqlite3"
    msg_success "SQLite configure."
}

set_postgres() {
    local default_db="${1:-myproject_db}"
    DB_CHOICE="postgres"
    DB_NAME="${DB_NAME:-$default_db}"
    DB_USER="${DB_USER:-postgres}"
    DB_PASS="${DB_PASS:-password}"
    DB_URL="postgres://${DB_USER}:${DB_PASS}@localhost:5432/${DB_NAME}"
    msg_success "PostgreSQL configure : $DB_NAME"
}

set_mysql() {
    local default_db="${1:-myproject_db}"
    DB_CHOICE="mysql"
    DB_NAME="${DB_NAME:-$default_db}"
    DB_USER="${DB_USER:-root}"
    DB_PASS="${DB_PASS:-password}"
    DB_URL="mysql://${DB_USER}:${DB_PASS}@localhost:3306/${DB_NAME}"
    msg_success "MySQL configure : $DB_NAME"
}

# ========================
#   Fichiers
# ========================

# Générer les fichiers .env et .env.example
# Usage: create_env_file /path/to/project [--secret-key key]
create_env_file() {
    local project_dir="${1:-.}"
    local secret_key=""

    shift || true
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --secret-key) secret_key="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    # Générer la clé si non fournie
    if [[ -z "$secret_key" ]]; then
        secret_key=$($PYTHON_CMD -c "import secrets; print(secrets.token_urlsafe(50))")
    fi

    cat <<EOF > "$project_dir/.env"
DEBUG=True
SECRET_KEY=$secret_key
DATABASE_URL=$DB_URL
EOF

    cat <<EOF > "$project_dir/.env.example"
DEBUG=True
SECRET_KEY=changeme!
DATABASE_URL=$DB_URL
EOF

    msg_success ".env et .env.example crees."
}
