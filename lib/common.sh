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
    if [[ "$OSTYPE" == "darwin"* ]]; then
        ifconfig | awk '/inet / && !/127.0.0.1/{print $2}' | head -1
    else
        ip route get 8.8.8.8 2>/dev/null | awk '{print $7; exit}'
    fi
}

# Vérifier qu'un port est disponible
port_available() {
    local port="$1"
    if command -v ss &>/dev/null; then
        ! ss -tlnp 2>/dev/null | grep -q ":$port "
    elif command -v lsof &>/dev/null; then
        ! lsof -i ":$port" &>/dev/null
    elif command -v netstat &>/dev/null; then
        ! netstat -tlnp 2>/dev/null | grep -q ":$port "
    else
        # Pas d'outil disponible, on considère le port libre
        return 0
    fi
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

# ========================
#   Licences
# ========================

# Generer un fichier LICENSE
# Usage: generate_license /path/to/project "mit" "Auteur"
generate_license() {
    local project_dir="${1:-.}"
    local license_type="${2:-none}"
    local author="${3:-}"
    local year
    year=$(date +%Y)

    case "$license_type" in
        mit)
            cat <<EOF > "$project_dir/LICENSE"
MIT License

Copyright (c) $year $author

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
            ;;
        gpl)
            cat <<EOF > "$project_dir/LICENSE"
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (c) $year $author

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
EOF
            ;;
        apache)
            cat <<EOF > "$project_dir/LICENSE"
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form.

      "Work" shall mean the work of authorship made available under the License.

      "Contribution" shall mean any work of authorship submitted to the Licensor.

      "Contributor" shall mean Licensor and any Legal Entity on behalf of whom
      a Contribution has been received by the Licensor.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      patent license to make, have made, use, offer to sell, sell,
      import, and otherwise transfer the Work.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work; and

      (d) If the Work includes a "NOTICE" text file, You must include
          a readable copy of the attribution notices contained
          within such NOTICE file.

   5. Submission of Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor.

   7. Disclaimer of Warranty. The Work is provided on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND.

   8. Limitation of Liability. In no event shall any Contributor be
      liable to You for damages.

   9. Accepting Warranty or Additional Liability.

   Copyright $year $author

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
EOF
            ;;
        none|*)
            return 0
            ;;
    esac

    if [[ "$license_type" != "none" ]]; then
        msg_success "Licence $license_type generee."
    fi
}
