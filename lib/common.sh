#!/bin/bash
# lib/common.sh — Fonctions communes : messages, validation, utilitaires

# ========================
#   Messages
# ========================
msg_success()  { echo "[OK] $*"; }
msg_error()    { echo "[ERR] $*" >&2; }
msg_warn()     { echo "[WARN] $*"; }
msg_info()     { echo "[INFO] $*"; }
msg_question() { echo -n "[?] $*"; }
msg_progress() { echo "[...] $*"; }
msg_result()   { echo "[=>] $*"; }
msg_cleanup()  { echo "[--] $*"; }

# ========================
#   Validation
# ========================

# Demander confirmation Oui/Non
# Usage: ask_yes_no "Question" && echo "Ok" || echo "Non"
ask_yes_no() {
    local prompt="${1:-Continuer ?}"
    msg_question "$prompt [O/n] "
    read -r reply
    [[ -z "$reply" || "$reply" =~ ^[OoYy]$ ]]
}

# Vérifier qu'une commande existe
# Usage: require_command git || exit 1
require_command() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        msg_error "$cmd est requis mais non installé."
        return 1
    fi
}

# Vérifier que plusieurs commandes existent
# Usage: require_commands git curl
require_commands() {
    local missing=()
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        msg_error "Commandes manquantes : ${missing[*]}"
        return 1
    fi
}

# ========================
#   Utilitaires
# ========================

# Obtenir l'IP LAN de la machine
get_lan_ip() {
    ip route get 8.8.8.8 2>/dev/null | awk '{print $7; exit}'
}

# Vérifier qu'un port est disponible
port_available() {
    local port="$1"
    ! ss -tlnp 2>/dev/null | grep -q ":$port " && \
    ! lsof -i ":$port" &>/dev/null
}

# Trouver un port disponible à partir d'un port de base
find_available_port() {
    local port="${1:-8000}"
    while ! port_available "$port" && [[ $port -lt 65535 ]]; do
        port=$((port + 1))
    done
    if [[ $port -ge 65535 ]]; then
        msg_error "Aucun port disponible trouvé."
        return 1
    fi
    echo "$port"
}

# Détecter le gestionnaire de paquets
detect_pkg_manager() {
    if command -v apt &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v brew &>/dev/null; then
        echo "brew"
    else
        echo "unknown"
    fi
}

# Détecter le type d'OS
detect_os() {
    case "$(uname -s)" in
        Linux*)   echo "linux" ;;
        Darwin*)  echo "macos" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

# Déterminer le shell de l'utilisateur
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
