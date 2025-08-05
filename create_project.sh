#!/bin/bash

# Répertoire de base pour les projets
BASE_DIR="$HOME/space_work"

# Valeurs par défaut
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
    echo
    exit 0
}

# Parsing des arguments
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

# Restaure les arguments restants
set -- "${ARGS[@]}"

# Vérifie le nom du projet
PROJECT_NAME=$1
if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Erreur : tu dois spécifier un nom de projet."
    echo "Utilise --help pour l'aide."
    exit 1
fi

# Crée la structure de base
PROJECT_DIR="$BASE_DIR/$PROJECT_NAME"
mkdir -p "$PROJECT_DIR"/{src,tests,docs}
echo "# $PROJECT_NAME" > "$PROJECT_DIR/README.md"

cd "$PROJECT_DIR" || exit

# Environnement virtuel
if $CREATE_VENV && command -v python3 &>/dev/null; then
    python3 -m venv venv
    echo "✅ Environnement virtuel créé."
fi

# Projet Django
if $CREATE_DJANGO; then
    if command -v django-admin &>/dev/null; then
        ./venv/bin/pip install django
        ./venv/bin/django-admin startproject config src/
        echo "✅ Projet Django initialisé dans src/"
    else
        echo "❌ Django n'est pas installé. Lance 'pip install django' d'abord."
    fi
fi

# Dépôt Git
if $INIT_GIT && command -v git &>/dev/null; then
    git init
    echo "✅ Dépôt Git initialisé."
fi

echo "🎉 Projet '$PROJECT_NAME' prêt dans $PROJECT_DIR"

