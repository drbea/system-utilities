#!/bin/bash

BASE_DIR="$HOME/space_work"

CREATE_VENV=true
INIT_GIT=false
CREATE_DJANGO=false

function show_help {
    echo "Usage: create_project [options] project_name"
    echo
    echo "Options:"
    echo "  --no-venv       Ne pas créer d'environnement virtuel Python"
    echo "  --git           Initialiser un dépôt Git"
    echo "  --django        Créer un projet Django (nécessite django installé)"
    echo "  --help          Affiche cette aide"
    exit 0
}

# Lire options
ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-venv) CREATE_VENV=false; shift ;;
        --git) INIT_GIT=true; shift ;;
        --django) CREATE_DJANGO=true; shift ;;
        --help) show_help ;;
        *) ARGS+=("$1"); shift ;;
    esac
done
set -- "${ARGS[@]}"

PROJECT_NAME=$1
if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Erreur : tu dois spécifier un nom de projet."
    exit 1
fi

PROJECT_DIR="$BASE_DIR/$PROJECT_NAME"
mkdir -p "$PROJECT_DIR"/{src,tests,docs}

echo "# $PROJECT_NAME" > "$PROJECT_DIR/README.md"
cd "$PROJECT_DIR" || exit

# Environnement virtuel
if $CREATE_VENV && command -v python3 &>/dev/null; then
    python3 -m venv venv
    echo "✅ Environnement virtuel créé."

    source venv/bin/activate
    pip install --upgrade pip

    if $CREATE_DJANGO; then
        pip install django
        django-admin startproject config src/
        echo "✅ Projet Django initialisé dans src/"
    fi

    pip freeze > requirements.txt
    echo "✅ requirements.txt généré."
fi

# Menu interactif pour le choix de la base
echo
echo "🔧 Choisis une base de données pour ton projet :"
echo "1) SQLite (par défaut, simple et local)"
echo "2) PostgreSQL"
echo "3) MySQL / MariaDB"
read -rp "Ton choix [1-3] : " db_choice

db_name="${PROJECT_NAME}_db"

case "$db_choice" in
    2)
        echo "🔐 Configuration PostgreSQL"
        read -rp "Nom de la base [$db_name]: " input_db
        read -rp "Utilisateur [postgres]: " db_user
        read -rp "Mot de passe [password]: " db_pass

        input_db=${input_db:-$db_name}
        db_user=${db_user:-postgres}
        db_pass=${db_pass:-password}

        DB_URL="postgres://${db_user}:${db_pass}@localhost:5432/${input_db}"
        ;;
    3)
        echo "🔐 Configuration MySQL / MariaDB"
        read -rp "Nom de la base [$db_name]: " input_db
        read -rp "Utilisateur [root]: " db_user
        read -rp "Mot de passe [password]: " db_pass

        input_db=${input_db:-$db_name}
        db_user=${db_user:-root}
        db_pass=${db_pass:-password}

        DB_URL="mysql://${db_user}:${db_pass}@localhost:3306/${input_db}"
        ;;
    *)
        echo "🗃️  Utilisation de SQLite (par défaut)"
        DB_URL="sqlite:///db.sqlite3"
        ;;
esac

# Fichier .env
cat <<EOF > .env
DEBUG=True
SECRET_KEY=changeme!
DATABASE_URL=$DB_URL
EOF

echo "✅ Fichier .env créé avec DATABASE_URL → $DB_URL"

# Git
if $INIT_GIT && command -v git &>/dev/null; then
    git init
    echo "✅ Dépôt Git initialisé."
fi

# Makefile
cat <<'EOF' > Makefile
setup:
	python3 -m venv venv
	venv/bin/pip install --upgrade pip
	venv/bin/pip install -r requirements.txt

run:
	venv/bin/python src/manage.py runserver

test:
	venv/bin/python -m unittest discover tests

freeze:
	venv/bin/pip freeze > requirements.txt

clean:
	rm -rf __pycache__ *.pyc venv
EOF

echo "✅ Makefile ajouté."
echo "🎉 Projet '$PROJECT_NAME' prêt dans $PROJECT_DIR"

