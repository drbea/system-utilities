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
    opts="--no-venv --venv-name --no-git --django --fastapi --flask --db --db-name --db-user --db-pass --author --license --python-version --yes --verbose --config --show-config --version --help"

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
    opts="--port --collectstatic --log-file --verbose --version --help"

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
#   Completions deploy_project
# ========================
_complete_deploy_project() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Options disponibles
    opts="--output --remote --remote-path --docker --include-venv --verbose --version --help"

    # Si on est apres une option qui attend un argument
    case "$prev" in
        --output)
            COMPREPLY=( $(compgen -d -- "$cur") )
            return 0
            ;;
        --remote)
            # Pas de completion pour user@host
            return 0
            ;;
        --remote-path)
            COMPREPLY=( $(compgen -d -- "$cur") )
            return 0
            ;;
    esac

    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
}

# ========================
#   Completions backup_db
# ========================
_complete_backup_db() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Options disponibles
    opts="--dir --no-compress --db-type --db-name --db-user --db-host --db-port --verbose --version --help"

    # Si on est apres une option qui attend un argument
    case "$prev" in
        --dir)
            COMPREPLY=( $(compgen -d -- "$cur") )
            return 0
            ;;
        --db-type)
            COMPREPLY=( $(compgen -W "sqlite postgres mysql" -- "$cur") )
            return 0
            ;;
        --db-name|--db-user|--db-host)
            return 0
            ;;
        --db-port)
            COMPREPLY=( $(compgen -W "5432 3306" -- "$cur") )
            return 0
            ;;
    esac

    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
}

# ========================
#   Completions check_project
# ========================
_complete_check_project() {
    local cur opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Options disponibles
    opts="--no-lint --no-tests --no-security --no-dependencies --fix --verbose --version --help"

    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
}

# ========================
#   Completions migrate_project
# ========================
_complete_migrate_project() {
    local cur opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Options disponibles
    opts="--make --check --verbose --version --help"

    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
}

# ========================
#   Completions run_tests
# ========================
_complete_run_tests() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Options disponibles
    opts="--verbose-output --coverage --pattern --verbose --version --help"

    # Si on est apres une option qui attend un argument
    case "$prev" in
        --pattern)
            # Proposer des noms de fichiers
            COMPREPLY=( $(compgen -f -X '!*.py' -- "$cur") )
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
complete -F _complete_deploy_project deploy_project
complete -F _complete_backup_db backup_db
complete -F _complete_check_project check_project
complete -F _complete_migrate_project migrate_project
complete -F _complete_run_tests run_tests
