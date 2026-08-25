#!/bin/bash
# uninstall.sh — Desinstallation de system-utilities
# Usage: uninstall.sh [options]

set -euo pipefail

# ========================
#   Configuration
# ========================
SYSTEM_UTILS_DIR="$HOME/.system-utilities"

# ========================
#   Couleurs
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
Usage: uninstall.sh [options]

Desinstalle system-utilities de votre machine.

Options:
  --force     Supprimer sans demander de confirmation
  --help      Affiche cette aide
EOF
    exit 0
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
#   Detection des liens existants
# ========================
find_symlinks() {
    local symlinks=()
    local paths=("$HOME/.local/bin" "/usr/local/bin" "$HOME/bin")

    for dir in "${paths[@]}"; do
        if [[ -d "$dir" ]]; then
            for cmd in create_project django_collab; do
                if [[ -L "$dir/$cmd" ]]; then
                    symlinks+=("$dir/$cmd")
                fi
            done
        fi
    done

    echo "${symlinks[@]}"
}

# ========================
#   Desinstallation
# ========================
uninstall() {
    local force=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force) force=true; shift ;;
            --help) show_help ;;
            *) shift ;;
        esac
    done

    # Verification
    if [[ ! -d "$SYSTEM_UTILS_DIR" ]]; then
        msg_warn "system-utilities n'est pas installe."
        exit 0
    fi

    # Trouver les liens existants
    local symlinks
    symlinks=$(find_symlinks)

    # Confirmation
    if ! $force; then
        echo
        msg_info "Elements a supprimer :"
        echo "  - Dossier : $SYSTEM_UTILS_DIR"
        for link in $symlinks; do
            echo "  - Lien    : $link"
        done
        echo
        echo -n "Confirmer la desinstallation ? [O/n] "
        read -r reply
        if [[ -n "$reply" && ! "$reply" =~ ^[OoYy]$ ]]; then
            msg_info "Desinstallation annulee."
            exit 0
        fi
    fi

    # Supprimer le dossier principal
    msg_progress "Suppression de $SYSTEM_UTILS_DIR..."
    rm -rf "$SYSTEM_UTILS_DIR"
    msg_success "Dossier supprime."

    # Supprimer les liens
    for link in $symlinks; do
        rm -f "$link"
        msg_success "Lien supprime : $link"
    done

    # Retirer du PATH
    local shell_rc
    shell_rc=$(detect_shell_rc)
    if [[ -f "$shell_rc" ]] && grep -q "# system-utilities" "$shell_rc"; then
        msg_progress "Nettoyage de $shell_rc..."
        sed -i '/# system-utilities/d' "$shell_rc" 2>/dev/null || true
        sed -i "\|export PATH.*system-utilities|d" "$shell_rc" 2>/dev/null || true
        msg_success "PATH nettoye."
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

    echo
    msg_success "Desinstallation terminee."
    msg_info "Redemarrez votre terminal pour appliquer les changements."
}

# ========================
#   Main
# ========================
uninstall "$@"
