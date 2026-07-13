# Plan de développement — system-utilities

> Document de suivi du refactoring et de l'ajout de features.
> Dernière mise à jour : 2026-07-13

---

## 🎯 Objectif

Transformer le projet en une **suite modulaire de commandes Bash installables**, sans dépendance externe, installable via un script `install.sh`, accessible depuis n'importe quel terminal.

---

## 📐 Architecture cible

```
system-utilities/
├── install.sh                  # Script d'installation (interactif + CLI)
├── uninstall.sh                # Désinstallation propre
├── lib/                        # Modules partagés ( Bash pur )
│   ├── common.sh               # Couleurs, icons, validation, messages
│   ├── python.sh               # Détection Python, gestion venv
│   ├── git.sh                  # Opérations Git (init, commit, etc.)
│   └── database.sh             # Config BDD (sqlite/postgres/mysql)
├── commands/                   # Commandes installables
│   ├── create_project          # Scaffolding projets Django (+ FastAPI/Flask plus tard)
│   └── django_collab           # Collaboration Django (dev server, firewall)
├── completions/                # Auto-complétion Bash
│   └── system-utilities.bash   # Completions pour toutes les commandes
├── docs/                       # Documentation de développement
│   └── DEVELOPMENT.md          # Ce fichier (suivi du plan)
└── README.md                   # Documentation utilisateur finale
```

---

## 📋 Étapes de développement

### Phase 1 : Refactoring modulaire ✅ TERMINEE

| # | Tâche | Statut | Notes |
|---|-------|--------|-------|
| 1.1 | Créer la structure `lib/`, `commands/`, `completions/`, `docs/` | ✅ | Dossiers créés |
| 1.2 | Extraire `lib/common.sh` (messages, validation) | ✅ | 8 fonctions msg_*, ask_yes_no, require_command, etc. |
| 1.3 | Extraire `lib/python.sh` (detect_python, create_venv, handle_missing_python) | ✅ | Mode hybride : demander/auto-install/instructions |
| 1.4 | Extraire `lib/git.sh` (init_git, create_gitignore) | ✅ | |
| 1.5 | Extraire `lib/database.sh` (setup_database, generate_db_url) | ✅ | |
| 1.6 | Refactorer `commands/create_project` pour sourcer les lib | ✅ | |
| 1.7 | Refactorer `commands/django_collab` pour sourcer les lib | ✅ | |
| 1.8 | Tester que les deux commandes fonctionnent identiquement | ✅ | Tests OK : Django + package generique |

### Phase 2 : Script d'installation ✅ TERMINEE

| # | Tâche | Statut | Notes |
|---|-------|--------|-------|
| 2.1 | Créer `install.sh` — détection OS (Linux/macOS/WSL) | ✅ | |
| 2.2 | Détection auto : `~/.local/bin/` ou `/usr/local/bin/` | ✅ | |
| 2.3 | Mode interactif : demander dossier, options | ✅ | |
| 2.4 | Mode CLI : `--install-dir`, `--force`, `--no-path` | ✅ | |
| 2.5 | Copie des fichiers vers `~/.system-utilities/` | ✅ | |
| 2.6 | Création des symlinks dans le dossier choisi | ✅ | |
| 2.7 | Mise à jour PATH dans `.bashrc`/`.zshrc` si nécessaire | ✅ | |
| 2.8 | Vérification post-install | ✅ | |
| 2.9 | Créer `uninstall.sh` | ✅ | Avec --force pour skipper la confirmation |

### Phase 3 : Auto-complétion Bash ✅ TERMINEE

| # | Tâche | Statut | Notes |
|---|-------|--------|-------|
| 3.1 | Créer `completions/system-utilities.bash` | ✅ | |
| 3.2 | Complétion des options pour `create_project` | ✅ | --no-venv, --venv-name, --django, --db, etc. |
| 3.3 | Complétion des options pour `django_collab` | ✅ | --port, --collectstatic, etc. |
| 3.4 | Installation auto des completions dans install.sh | ✅ | |
| 3.5 | Tester le fonctionnement du Tab | ✅ | |

### Phase 4 : Enrichissement des commandes existantes

| # | Tâche | Statut | Notes |
|---|-------|--------|-------|
| 4.1 | `create_project` : `--author` | ⬜ | |
| 4.2 | `create_project` : `--license` | ⬜ | |
| 4.3 | `create_project` : `--python-version` | ⬜ | |
| 4.4 | Enrichir le Makefile | ⬜ | |
| 4.5 | `django_collab` : `--port` paramétrable | ⬜ | |
| 4.6 | `django_collab` : auto-détection port dispo | ⬜ | |
| 4.7 | `django_collab` : `--collectstatic` | ⬜ | |
| 4.8 | `django_collab` : logs en fichier | ⬜ | |
| 4.9 | `create_project` : `--venv-name` pour nom du venv | ✅ | Defaut: .venv |
| 4.10 | Django : split settings (base.py, dev.py, prod.py) | ✅ | base.py=commun, dev.py=DEBUG, prod.py=dj-database-url |

### Phase 5 : FastAPI / Flask

| # | Tâche | Statut | Notes |
|---|-------|--------|-------|
| 5.1 | `create_project` : `--fastapi` | ⬜ | |
| 5.2 | `create_project` : `--flask` | ⬜ | |
| 5.3 | Templates de structure par framework | ⬜ | |
| 5.4 | Makefile adapté par framework | ⬜ | |

### Phase 6 : Nouvelles commandes

| # | Tâche | Statut | Notes |
|---|-------|--------|-------|
| 6.1 | `deploy_project` | ⬜ | |
| 6.2 | `backup_db` | ⬜ | |
| 6.3 | `check_project` | ⬜ | |

### Phase 7 : Documentation

| # | Tâche | Statut | Notes |
|---|-------|--------|-------|
| 7.1 | README.md final | ⬜ | |
| 7.2 | `--help` complet par commande | ⬜ | |
| 7.3 | Exemples dans la doc | ⬜ | |

---

## 📌 Conventions de développement

- **Langage** : Bash pur (`#!/bin/bash`, `set -euo pipefail`)
- **Aucune dépendance externe**
- **Style** : texte brut, aucune icône/emoji (compatibilité max)
- **Messages** : format `[TAG] message` via fonctions `lib/common.sh`

| Fonction | Format | Usage |
|---|---|---|
| `msg_success` | `[OK]` | Action réussie |
| `msg_error` | `[ERR]` | Erreur fatale (stderr) |
| `msg_warn` | `[WARN]` | Avertissement |
| `msg_info` | `[INFO]` | Information générale |
| `msg_question` | `[?]` | Question (sans newline) |
| `msg_progress` | `[...]` | Avancement opération |
| `msg_result` | `[=>]` | Résultat (URL, chemin) |
| `msg_cleanup` | `[--]` | Nettoyage/fermeture |

- **Validation** : toujours vérifier les inputs utilisateur
- **Mode non-interactif** : supporter `--yes` ou flags équivalents
- **Compatible** : Linux, macOS, WSL, Git Bash (Windows)

### Décisions techniques

| Décision | Choix | Justification |
|---|---|---|
| **Python manquant** | Hybride : demander → auto-install ou instructions par OS | Pas de modif système sans consentement |
| **Gestionnaire paquets** | Détection auto (apt, yum, brew, dnf, pacman) | Couvre la majorité des systèmes |

---

## 📅 Historique

| Date | Action |
|------|--------|
| 2026-07-13 | Création du plan, choix architecture modulaire |
| 2026-07-13 | Décision : sans icônes, format `[TAG] message` |
| 2026-07-13 | Décision : gestion Python manquant en mode hybride |
| 2026-07-13 | Création dossiers `lib/`, `commands/`, `completions/`, `docs/` |
