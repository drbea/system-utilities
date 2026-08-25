#!/bin/bash
# install.sh — Installation de system-utilities
# Usage: install.sh [options]

set -euo pipefail

# ========================
#   Configuration
# ========================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR=""
FORCE_INSTALL=false
ADD_TO_PATH=true
INTERACTIVE=true

# Dossier de destination des lib + commands
SYSTEM_UTILS_DIR="$HOME/.system-utilities"

# ========================
#   Couleurs (pas de dependance a lib/ pour l'install)
# ========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

msg_success()  { echo -e "${GREEN}[OK]${NC} $*"; }
msg_error()    { echo -e "${RED}[ERR]${NC} $*" >&2; }
msg_warn()     { echo -e "${YELLOW}[WARN]${NC} $*"; }
msg_info()     { echo "[INFO] $*"; }
msg_progress() { echo "[...] $*"; }

# ========================
#   Aide
# ========================
show_help() {
    cat <<EOF
Usage: install.sh [options]

Installe system-utilities sur votre machine.

Options:
  --install-dir <dir>   Dossier d'installation des symlinks (defaut: auto)
  --force               Ecraser une installation existante
  --no-path             Ne pas modifier le PATH
  --uninstall           Desinstaller system-utilities
  --help                Affiche cette aide

Exemples:
  ./install.sh                      # Installation interactive
  ./install.sh --install-dir /usr/local/bin   # Installation systeme
  ./install.sh --force              # Reinstallation
  ./install.sh --uninstall          # Desinstallation
EOF
    exit 0
}

# ========================
#   Detection OS
# ========================
detect_os() {
    case "$(uname -s)" in
        Linux*)   echo "linux" ;;
        Darwin*)  echo "macos" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

# ========================
#   Detection dossier install
# ========================
detect_install_dir() {
    local os
    os=$(detect_os)

    # Si un dossier est force, l'utiliser
    if [[ -n "$INSTALL_DIR" ]]; then
        echo "$INSTALL_DIR"
        return 0
    fi

    # Verifier ~/.local/bin (accessible en ecriture)
    if [[ -d "$HOME/.local/bin" ]] && [[ -w "$HOME/.local/bin" ]]; then
        echo "$HOME/.local/bin"
        return 0
    fi

    # Verifier si on peut creer ~/.local/bin
    if mkdir -p "$HOME/.local/bin" 2>/dev/null; then
        echo "$HOME/.local/bin"
        return 0
    fi

    # Fallback : /usr/local/bin (necessite sudo)
    if [[ -w "/usr/local/bin" ]]; then
        echo "/usr/local/bin"
        return 0
    fi

    # Dernier recours : demander a l'utilisateur
    echo "/usr/local/bin"
}

# ========================
#   Verification sudo
# ========================
needs_sudo() {
    local dir="$1"
    if [[ -w "$dir" ]]; then
        return 0
    else
        return 1
    fi
}

# ========================
#   Detection shell RC
# ========================
detect_shell_rc() {
    local shell_name
    shell_name=$(basename "${SHELL:-/bin/bash}")
    case "$shell_name" in
        zsh)  echo "$HOME/.zshrc" ;;
        bash) echo "$HOME/.bashrc" ;;
        fish) echo "$HOME/.config/fish/config.fish" ;;
        *)    echo "$HOME/.bashrc" ;;
    esac
}

# ========================
#   Completions
# ========================
install_completions() {
    local use_sudo="${1:-}"
    local completion_file="$SYSTEM_UTILS_DIR/completions/system-utilities.bash"

    if [[ ! -f "$completion_file" ]]; then
        msg_warn "Fichier de completions non trouve."
        return 0
    fi

    # Dossier cible pour les completions
    local completion_dir=""
    local shell_rc
    shell_rc=$(detect_shell_rc)

    # Detecter le meilleur emplacement
    if [[ -d "$HOME/.local/share/bash-completion/completions" ]]; then
        completion_dir="$HOME/.local/share/bash-completion/completions"
    elif [[ -d "/etc/bash_completion.d" ]] && [[ -w "/etc/bash_completion.d" ]]; then
        completion_dir="/etc/bash_completion.d"
    else
        # Creer le dossier local
        mkdir -p "$HOME/.local/share/bash-completion/completions"
        completion_dir="$HOME/.local/share/bash-completion/completions"
    fi

    # Copier le fichier de completions
    cp "$completion_file" "$completion_dir/system-utilities.bash"
    msg_success "Completions installees dans $completion_dir"

    # Ajouter le source dans le shell RC si pas deja present
    if [[ -f "$shell_rc" ]] && ! grep -q "system-utilities.bash" "$shell_rc"; then
        echo "" >> "$shell_rc"
        echo "# system-utilities completions" >> "$shell_rc"
        echo "if [[ -f '$completion_dir/system-utilities.bash' ]]; then" >> "$shell_rc"
        echo "    source '$completion_dir/system-utilities.bash'" >> "$shell_rc"
        echo "fi" >> "$shell_rc"
        msg_success "Source ajoute dans $shell_rc"
    fi
}

# ========================
#   Installation
# ========================
install() {
    # Verifier installation existante
    if $INTERACTIVE; then
        check_existing_install || true
    fi

    msg_progress "Detection du systeme..."
    local os
    os=$(detect_os)
    msg_info "OS detecte : $os"

    # Detecter le dossier d'installation
    local install_dir
    install_dir=$(detect_install_dir)
    msg_info "Dossier d'installation : $install_dir"

    # Verifier si sudo est necessaire
    local use_sudo=""
    if ! needs_sudo "$install_dir"; then
        msg_warn "Droit d'ecriture insuffisant — sudo requis."
        use_sudo="sudo"
    fi

    # Mode interactif
    if $INTERACTIVE; then
        echo
        echo "Configuration de l'installation :"
        echo "  Dossier des scripts : $SYSTEM_UTILS_DIR"
        echo "  Dossier des liens   : $install_dir"
        echo "  Ajout au PATH       : $([ "$ADD_TO_PATH" = true ] && echo "Oui" || echo "Non")"
        echo
        echo -n "Continuer ? [O/n] "
        read -r reply
        if [[ -n "$reply" && ! "$reply" =~ ^[OoYy]$ ]]; then
            msg_info "Installation annulee."
            exit 0
        fi
    fi

    # Creer le dossier de destination
    msg_progress "Creation de $SYSTEM_UTILS_DIR..."
    mkdir -p "$SYSTEM_UTILS_DIR/lib"
    mkdir -p "$SYSTEM_UTILS_DIR/commands"
    mkdir -p "$SYSTEM_UTILS_DIR/completions"

    # Copier les fichiers
    msg_progress "Copie des fichiers..."
    cp -r "$SCRIPT_DIR/lib/"* "$SYSTEM_UTILS_DIR/lib/"
    cp -r "$SCRIPT_DIR/commands/"* "$SYSTEM_UTILS_DIR/commands/"
    cp -r "$SCRIPT_DIR/completions/"* "$SYSTEM_UTILS_DIR/completions/" 2>/dev/null || true

    # Rendre les commandes executables
    chmod +x "$SYSTEM_UTILS_DIR/commands/"*

    # Creer les symlinks
    msg_progress "Creation des liens symboliques..."
    for cmd in "$SYSTEM_UTILS_DIR/commands/"*; do
        local cmd_name
        cmd_name=$(basename "$cmd")
        $use_sudo ln -sf "$cmd" "$install_dir/$cmd_name"
    done

    # Installer les completions Bash
    install_completions "$use_sudo"

    # Ajouter au PATH si necessaire
    if $ADD_TO_PATH; then
        add_to_path "$install_dir"
    fi

    # Verification post-install
    verify_install "$install_dir"
}

# ========================
#   PATH
# ========================
add_to_path() {
    local dir="$1"
    local shell_rc
    shell_rc=$(detect_shell_rc)

    # Verifier si le dossier est deja dans le PATH
    if [[ ":$PATH:" == *":$dir:"* ]]; then
        msg_info "Dossier deja dans le PATH."
        return 0
    fi

    # Verifier si le fichier de config existe deja
    if [[ -f "$shell_rc" ]] && grep -q "$dir" "$shell_rc"; then
        msg_info "PATH deja configure dans $shell_rc"
        return 0
    fi

    msg_progress "Ajout de $dir au PATH dans $shell_rc..."
    echo "" >> "$shell_rc"
    echo "# system-utilities" >> "$shell_rc"
    echo "export PATH=\"\$PATH:$dir\"" >> "$shell_rc"

    msg_success "PATH mis a jour. Redemarrez votre terminal ou executez :"
    msg_info "  source $shell_rc"
}

# ========================
#   Verification
# ========================
verify_install() {
    local install_dir="$1"
    local all_ok=true

    echo
    msg_progress "Verification de l'installation..."

    for cmd in create_project django_collab deploy_project backup_db check_project; do
        if [[ -x "$install_dir/$cmd" ]]; then
            msg_success "$cmd installe"
        else
            msg_error "$cmd non trouve dans $install_dir"
            all_ok=false
        fi
    done

    if $all_ok; then
        echo
        msg_success "Installation terminee !"
        echo
        msg_info "Commandes disponibles :"
        echo "  create_project   — Creer un projet Python/Django/FastAPI/Flask"
        echo "  django_collab    — Serveur Django pour la collaboration"
        echo "  deploy_project   — Deploier un projet"
        echo "  backup_db        — Sauvegarder une base de donnees"
        echo "  check_project    — Verifier un projet"
        echo
        msg_info "Redemarrez votre terminal ou executez :"
        echo "  source $(detect_shell_rc)"
    else
        msg_error "Des erreurs sont survenues pendant l'installation."
        exit 1
    fi
}

# ========================
#   Desinstallation
# ========================
uninstall() {
    msg_progress "Desinstallation de system-utilities..."

    # Supprimer le dossier principal
    if [[ -d "$SYSTEM_UTILS_DIR" ]]; then
        rm -rf "$SYSTEM_UTILS_DIR"
        msg_success "Dossier $SYSTEM_UTILS_DIR supprime."
    fi

    # Supprimer les symlinks
    local install_dir
    install_dir=$(detect_install_dir)

    for cmd in create_project django_collab deploy_project backup_db check_project; do
        if [[ -L "$install_dir/$cmd" ]]; then
            rm -f "$install_dir/$cmd"
            msg_success "Lien $cmd supprime."
        fi
    done

    # Retirer du PATH
    local shell_rc
    shell_rc=$(detect_shell_rc)
    if [[ -f "$shell_rc" ]]; then
        sed -i '/# system-utilities/d' "$shell_rc" 2>/dev/null || true
        sed -i "\|export PATH.*$SYSTEM_UTILS_DIR|d" "$shell_rc" 2>/dev/null || true
    fi

    # Supprimer les completions
    local completion_files=(
        "$HOME/.local/share/bash-completion/completions/system-utilities.bash"
        "/etc/bash_completion.d/system-utilities.bash"
    )
    for cf in "${completion_files[@]}"; do
        if [[ -f "$cf" ]]; then
            rm -f "$cf"
            msg_success "Completions supprimees : $cf"
        fi
    done

    msg_success "Desinstallation terminee."
}

# ========================
#   Verification install existante
# ========================
check_existing_install() {
    if [[ ! -d "$SYSTEM_UTILS_DIR" ]]; then
        return 1
    fi

    msg_warn "system-utilities est deja installe dans $SYSTEM_UTILS_DIR"

    while true; do
        echo
        echo "Que souhaitez-vous faire ?"
        echo "  1) Mettre a jour"
        echo "  2) Reinstaller (nettoyer et reinstaller)"
        echo "  3) Desinstaller"
        echo "  4) Annuler"
        echo
        msg_question "Votre choix [1-4] : "
        read -r choice

        case "$choice" in
            1) return 0 ;;
            2) uninstall; return 0 ;;
            3) uninstall; exit 0 ;;
            4) msg_info "Annule."; exit 0 ;;
            *) msg_error "Choix invalide. Entrez un nombre entre 1 et 4." ;;
        esac
    done
}

# ========================
#   Parse des options
# ========================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --install-dir) INSTALL_DIR="$2"; shift 2 ;;
        --force) FORCE_INSTALL=true; INTERACTIVE=false; shift ;;
        --no-path) ADD_TO_PATH=false; shift ;;
        --uninstall) uninstall; exit 0 ;;
        --help) show_help ;;
        *) msg_error "Option inconnue : $1"; show_help ;;
    esac
done

# ========================
#   Main
# ========================
install
