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
    opts="--no-venv --venv-name --no-git --django --db --db-name --db-user --db-pass --author --license --python-version --yes --help"

    # Si on est apres une option qui attend un argument
    case "$prev" in
        --venv-name)
            COMPREPLY=( $(compgen -W ".venv env venv virtualenv" -- "$cur") )
            return 0
            ;;
        --db)
            COMPREPLY=( $(compgen -W "sqlite postgres mysql" -- "$cur") )
            return 0
            ;;
        --license)
            COMPREPLY=( $(compgen -W "mit gpl apache none" -- "$cur") )
            return 0
            ;;
        --python-version)
            COMPREPLY=( $(compgen -W "3.10 3.11 3.12 3.13" -- "$cur") )
            return 0
            ;;
        --db-name|--db-user|--db-pass|--author)
            return 0
            ;;
    esac

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
    opts="--port --collectstatic --log-file --help"

    # Si on est apres une option qui attend un argument
    case "$prev" in
        --port)
            COMPREPLY=( $(compgen -W "8000 8080 3000 5000" -- "$cur") )
            return 0
            ;;
        --log-file)
            # Proposer des noms de fichiers
            COMPREPLY=( $(compgen -f -X '!*.log' -- "$cur") )
            return 0
            ;;
    esac

    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
}

# ========================
#   Enregistrement des completions
# ========================
complete -F _complete_create_project create_project
complete -F _complete_django_collab django_collab
