#!/bin/bash
# lib/python.sh — Détection Python, gestion venv, installation hybride

# Répertoire du script lib/
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/common.sh"

PYTHON_CMD=""

# ========================
#   Détection Python
# ========================

# Détecter Python disponible
# Met à jour PYTHON_CMD ou affiche erreur
detect_python() {
    if command -v python3 &>/dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &>/dev/null; then
        PYTHON_CMD="python"
    else
        return 1
    fi
}

# Vérifier Python + venv, proposer installation si manquant
# Usage: ensure_python
ensure_python() {
    if detect_python; then
        msg_success "Python détecté : $($PYTHON_CMD --version 2>&1)"
        return 0
    fi

    msg_warn "Python n'est pas installé."
    echo
    echo "Options :"
    echo "  1) Installer automatiquement (nécessite sudo)"
    echo "  2) Afficher les instructions et quitter"
    echo
    msg_question "Votre choix [1/2] : "
    read -r choice

    case "$choice" in
        1) install_python ;;
        2) show_python_instructions; return 1 ;;
        *) msg_error "Choix invalide."; return 1 ;;
    esac
}

# ========================
#   Installation Python
# ========================

# Installer Python via le gestionnaire de paquets détecté
install_python() {
    local pkg_manager
    pkg_manager=$(detect_pkg_manager)

    msg_progress "Installation de Python via $pkg_manager..."

    case "$pkg_manager" in
        apt)
            sudo apt update && sudo apt install -y python3 python3-venv python3-pip
            ;;
        dnf)
            sudo dnf install -y python3 python3-pip
            ;;
        yum)
            sudo yum install -y python3 python3-pip
            ;;
        pacman)
            sudo pacman -S --noconfirm python python-pip
            ;;
        brew)
            brew install python3
            ;;
        *)
            msg_error "Gestionnaire de paquets inconnu : $pkg_manager"
            show_python_instructions
            return 1
            ;;
    esac

    if detect_python; then
        msg_success "Python installé : $($PYTHON_CMD --version 2>&1)"
    else
        msg_error "L'installation a échoué."
        show_python_instructions
        return 1
    fi
}

# Afficher les instructions d'installation par OS
show_python_instructions() {
    local os
    os=$(detect_os)
    echo
    msg_info "Instructions d'installation de Python :"
    echo
    case "$os" in
        linux)
            local pkg_manager
            pkg_manager=$(detect_pkg_manager)
            case "$pkg_manager" in
                apt)     echo "  sudo apt update && sudo apt install python3 python3-venv python3-pip" ;;
                dnf)     echo "  sudo dnf install python3 python3-pip" ;;
                yum)     echo "  sudo yum install python3 python3-pip" ;;
                pacman)  echo "  sudo pacman -S python python-pip" ;;
                *)       echo "  Installe Python depuis https://www.python.org/downloads/" ;;
            esac
            ;;
        macos)
            echo "  brew install python3"
            echo "  # ou télécharger depuis https://www.python.org/downloads/"
            ;;
        windows)
            echo "  Télécharger depuis https://www.python.org/downloads/"
            echo "  (activer 'Add Python to PATH' à l'installation)"
            ;;
        *)
            echo "  https://www.python.org/downloads/"
            ;;
    esac
    echo
}

# ========================
#   Gestion venv
# ========================

# Créer un environnement virtuel
# Usage: create_venv /path/to/project [venv_name]
create_venv() {
    local project_dir="${1:-.}"
    local venv_name="${2:-.venv}"
    local venv_dir="$project_dir/$venv_name"

    if [[ -d "$venv_dir" ]]; then
        msg_warn "Le dossier $venv_name existe déjà."
        return 0
    fi

    msg_progress "Création de l'environnement virtuel..."
    $PYTHON_CMD -m venv "$venv_dir"
    msg_success "Environnement virtuel créé : $venv_dir"
}

# Activer l'environnement virtuel
# Usage: activate_venv /path/to/project [venv_name]
activate_venv() {
    local project_dir="${1:-.}"
    local venv_name="${2:-.venv}"
    local venv_dir="$project_dir/$venv_name"

    if [[ ! -d "$venv_dir" ]]; then
        msg_error "Aucun environnement $venv_name trouvé dans $project_dir"
        return 1
    fi

    # Détecter Windows (MSYS/Git Bash)
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win"* ]]; then
        source "$venv_dir/Scripts/activate"
    else
        source "$venv_dir/bin/activate"
    fi
}

# Mettre à jour pip dans le venv
# Usage: upgrade_pip /path/to/project [venv_name]
upgrade_pip() {
    local project_dir="${1:-.}"
    local venv_name="${2:-.venv}"
    local pip_cmd

    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win"* ]]; then
        pip_cmd="$project_dir/$venv_name/Scripts/pip"
    else
        pip_cmd="$project_dir/$venv_name/bin/pip"
    fi

    if [[ -x "$pip_cmd" ]]; then
        msg_progress "Mise à jour de pip..."
        "$pip_cmd" install --upgrade pip --quiet
    fi
}

# Vérifier que le venv existe et est valide
# Usage: validate_venv /path/to/project [venv_name]
validate_venv() {
    local project_dir="${1:-.}"
    local venv_name="${2:-.venv}"
    local venv_dir="$project_dir/$venv_name"

    if [[ ! -d "$venv_dir" ]]; then
        msg_error "Pas de dossier $venv_name dans $project_dir"
        return 1
    fi

    if [[ ! -f "$venv_dir/bin/python" ]] && [[ ! -f "$venv_dir/Scripts/python.exe" ]]; then
        msg_error "Le venv semble corrompu (python manquant)"
        return 1
    fi

    return 0
}

# ========================
#   Django Settings Split
# ========================

# Separer les settings Django en base.py, dev.py, prod.py
# Usage: split_django_settings /path/to/project
split_django_settings() {
    local project_dir="${1:-.}"
    local settings_dir="$project_dir/src/config"
    local settings_file="$settings_dir/settings.py"

    if [[ ! -f "$settings_file" ]]; then
        msg_warn "Pas de settings.py trouve — split ignore."
        return 0
    fi

    msg_progress "分离ation des settings Django..."

    # Creer les fichiers de settings
    create_base_settings "$settings_file"
    create_dev_settings "$settings_dir"
    create_prod_settings "$settings_dir"

    # Mettre a jour manage.py pour utiliser DJANGO_SETTINGS_MODULE
    update_manage_py "$project_dir"

    # Mettre a jour wsgi.py et asgi.py
    update_wsgi_asgi "$settings_dir"

    msg_success "Settings separes : base.py, dev.py, prod.py"
}

# Settings de base (communs)
create_base_settings() {
    local original="$1"
    local output="$(dirname "$original")/base.py"

    cat <<'EOF' > "$output"
"""
Settings de base — partie commune a tous les environnements.
"""
import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = os.getenv('SECRET_KEY', 'changeme!')

DEBUG = False

ALLOWED_HOSTS = []

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

DATABASES = {}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Europe/Paris'
USE_I18N = True
USE_TZ = True

STATIC_URL = 'static/'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
EOF
}

# Settings de developpement
create_dev_settings() {
    local settings_dir="$1"
    local output="$settings_dir/dev.py"

    cat <<'EOF' > "$output"
"""
Settings pour le developpement.
"""
from .base import *

DEBUG = True

ALLOWED_HOSTS = ['*']

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

INSTALLED_APPS += [
    'debug_toolbar',
]

MIDDLEWARE += [
    'debug_toolbar.middleware.DebugToolbarMiddleware',
]

INTERNAL_IPS = ['127.0.0.1']

CORS_ALLOW_ALL_ORIGINS = True
EOF
}

# Settings de production
create_prod_settings() {
    local settings_dir="$1"
    local output="$settings_dir/prod.py"

    cat <<'EOF' > "$output"
"""
Settings pour la production.
"""
import dj_database_url
from .base import *

DEBUG = False

SECRET_KEY = os.getenv('SECRET_KEY')
if not SECRET_KEY:
    raise ValueError("SECRET_KEY doit etre defini en production")

ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', '').split(',')

DATABASES = {
    'default': dj_database_url.config(
        default=os.getenv('DATABASE_URL', 'sqlite:///db.sqlite3'),
        conn_max_age=600,
    )
}

SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True
EOF
}

# Mettre a jour manage.py
update_manage_py() {
    local project_dir="$1"
    local manage_py="$project_dir/src/manage.py"

    if [[ ! -f "$manage_py" ]]; then
        return 0
    fi

    cat <<'EOF' > "$manage_py"
#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys


def main():
    """Run administrative tasks."""
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.dev')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()
EOF
}

# Mettre a jour wsgi.py et asgi.py
update_wsgi_asgi() {
    local settings_dir="$1"

    cat <<'EOF' > "$settings_dir/wsgi.py"
"""
WSGI config for config project.
"""
import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.prod')
application = get_wsgi_application()
EOF

    cat <<'EOF' > "$settings_dir/asgi.py"
"""
ASGI config for config project.
"""
import os
from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.prod')
application = get_asgi_application()
EOF
}
