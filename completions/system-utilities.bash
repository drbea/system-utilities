#!/bin/bash
# completions/system-utilities.bash — Auto-completion Bash pour system-utilities
# Charger : source /path/to/system-utilities.bash
# Ou placer dans /etc/bash_completion.d/ ou ~/.local/share/bash-completion/

# ========================
#   Completions create_project
# ========================
_complete_create_project() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Options disponibles
    opts="--no-venv --venv-name --no-git --django --db --db-name --db-user --db-pass --yes --help"

    # Si on est apres une option qui attend un argument
    case "$prev" in
        --venv-name)
            # Proposer des noms de venv courants
            COMPREPLY=( $(compgen -W ".venv env venv virtualenv" -- "$cur") )
            return 0
            ;;
        --db)
            COMPREPLY=( $(compgen -W "sqlite postgres mysql" -- "$cur") )
            return 0
            ;;
        --db-name|--db-user|--db-pass)
            # Pas de completion pour les valeurs
            return 0
            ;;
    esac

    # Completion des options
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
}

# ========================
#   Completions django_collab
# ========================
_complete_django_collab() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Options disponibles
    opts="--port --collectstatic --help"

    # Si on est apres une option qui attend un argument
    case "$prev" in
        --port)
            # Proposer des ports courants
            COMPREPLY=( $(compgen -W "8000 8080 3000 5000" -- "$cur") )
            return 0
            ;;
    esac

    # Completion des options
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
}

# ========================
#   Enregistrement des completions
# ========================
complete -F _complete_create_project create_project
complete -F _complete_django_collab django_collab
