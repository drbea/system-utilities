# system-utilities

Suite d'outils Bash pour creer, gerer et deployer des projets Python web.

## Installation

```bash
git clone https://github.com/drbea/system-utilities.git
cd system-utilities
./install.sh
```

Redemarrez votre terminal apres l'installation.

## Commandes disponibles

| Commande | Description |
|----------|-------------|
| `create_project` | Creer un projet Python/Django/FastAPI/Flask |
| `django_collab` | Serveur Django pour la collaboration LAN |
| `deploy_project` | Deploier un projet (archive ou serveur distant) |
| `backup_db` | Sauvegarder une base de donnees |
| `check_project` | Verifier un projet (lint, tests, securite) |
| `migrate_project` | Gerer les migrations Django |
| `run_tests` | Lancer les tests d'un projet |
| `yt_download` | Telecharger cours videos, playlists et livres audio |

---

## Options globales

Toutes les commandes supportent :

| Option | Description |
|--------|-------------|
| `--version` | Afficher la version |
| `--verbose` | Mode debug (plus d'infos) |
| `--help` | Afficher l'aide |

---

## create_project

Creer rapidement un projet Python avec environnement virtuel, Git et dependances.

### Exemples

```bash
# Projet Django
create_project --django mon_projet

# Projet FastAPI
create_project --fastapi mon_api

# Projet Flask
create_project --flask mon_site

# Avec base PostgreSQL
create_project --django --db postgres --db-name blog_db blog

# Mode non interactif
create_project --django --yes mon_projet
```

### Options

| Option | Description |
|--------|-------------|
| `--django` | Creer un projet Django |
| `--fastapi` | Creer un projet FastAPI |
| `--flask` | Creer un projet Flask |
| `--no-venv` | Ne pas creer d'environnement virtuel |
| `--venv-name <nom>` | Nom du dossier venv (defaut: .venv) |
| `--no-git` | Ne pas initialiser Git |
| `--db <type>` | Base de donnees : sqlite, postgres, mysql |
| `--db-name <nom>` | Nom de la base de donnees |
| `--db-user <user>` | Utilisateur de la BDD |
| `--db-pass <pass>` | Mot de passe de la BDD |
| `--author <nom>` | Auteur (pour le README et la licence) |
| `--license <type>` | Licence : mit, gpl, apache, none |
| `--python-version <v>` | Version de Python (ex: 3.12) |
| `--yes` | Mode non interactif |
| `--config` | Ouvrir le fichier de configuration |
| `--show-config` | Afficher la configuration actuelle |

### Configuration

Definir des valeurs par defaut :

```bash
create_project --config
```

Fichier `~/.system-utilities/config` :

```
AUTHOR=Mon Nom
DB=sqlite
VENV_NAME=.venv
LICENSE=mit
```

### Structure generee

```
mon_projet/
├── .venv/
├── src/
│   └── core/          # ou mon_package/
├── tests/
├── docs/
├── .env
├── .env.example
├── requirements.txt
├── Makefile
├── .gitignore
└── README.md
```

---

## django_collab

Lancer un serveur de developpement Django pour la collaboration sur le reseau local.

### Exemples

```bash
# Lancer dans le dossier courant
cd mon_projet
django_collab

# Port personnalise
django_collab --port 8080

# Avec collectstatic
django_collab --collectstatic

# Avec logs dans un fichier
django_collab --log-file serveur.log
```

### Options

| Option | Description |
|--------|-------------|
| `--port <port>` | Port du serveur (defaut: 8000, 0=auto) |
| `--collectstatic` | Lancer collectstatic avant le serveur |
| `--log-file <chemin>` | Rediriger les logs vers un fichier |

Le serveur demarre sur `0.0.0.0` pour etre accessible depuis les autres machines du reseau.

---

## deploy_project

Preparer ou effectuer le deploiement d'un projet.

### Exemples

```bash
# Creer une archive de deploiement
deploy_project

# Creer un Dockerfile
deploy_project --docker

# Deploier sur un serveur distant
deploy_project --remote user@mon-serveur --remote-path /opt/mon_app
```

### Options

| Option | Description |
|--------|-------------|
| `--output <dir>` | Repertoire de sortie (defaut: deploy/) |
| `--remote <user@host>` | Deploier sur un serveur distant (SSH) |
| `--remote-path <path>` | Chemin distant sur le serveur |
| `--docker` | Creer un Dockerfile |
| `--include-venv` | Inclure l'environnement virtuel |

---

## backup_db

Sauvegarder la base de donnees d'un projet.

### Exemples

```bash
# Sauvegarde SQLite (detecte automatiquement)
backup_db

# Sauvegarde PostgreSQL
backup_db --db-type postgres --db-name mon_blog

# Sans compression
backup_db --no-compress
```

### Options

| Option | Description |
|--------|-------------|
| `--dir <chemin>` | Repertoire de sauvegarde (defaut: backups/) |
| `--no-compress` | Ne pas compresser l'archive |
| `--db-type <type>` | Type de BDD : sqlite, postgres, mysql |
| `--db-name <nom>` | Nom de la base de donnees |
| `--db-user <user>` | Utilisateur de la BDD |
| `--db-host <host>` | Host de la BDD (defaut: localhost) |
| `--db-port <port>` | Port de la BDD |

---

## check_project

Verifier l'etat d'un projet (lint, tests, securite, dependances).

### Exemples

```bash
# Verification complete
check_project

# Sans les tests
check_project --no-tests

# Avec correction automatique
check_project --fix
```

### Options

| Option | Description |
|--------|-------------|
| `--no-lint` | Passer la verification du lint |
| `--no-tests` | Passer les tests |
| `--no-security` | Passer la verification de securite |
| `--no-dependencies` | Passer la verification des dependances |
| `--fix` | Tenter de corriger les problemes |

---

## migrate_project

Gerer les migrations Django.

### Exemples

```bash
# Verifier les migrations en attente
migrate_project --check

# Generer et appliquer les migrations
migrate_project --make

# Appliquer les migrations
migrate_project
```

### Options

| Option | Description |
|--------|-------------|
| `--make` | Generer les migrations manquantes |
| `--check` | Verifier les migrations en attente |

---

## run_tests

Lancer les tests d'un projet.

### Exemples

```bash
# Lancer tous les tests
run_tests

# Avec couverture
run_tests --coverage

# Affichage detaille
run_tests --verbose-output

# Un seul fichier de test
run_tests --pattern "test_models.py"
```

### Options

| Option | Description |
|--------|-------------|
| `--verbose-output` | Affichage detaille des tests |
| `--coverage` | Generer un rapport de couverture |
| `--pattern <glob>` | Pattern de fichiers de tests |

---

## Tests

Lancer les tests automatises :

```bash
./tests/test_commands.sh
```

---

## Desinstallation

```bash
./uninstall.sh
```

Ou via la commande d'installation :

```bash
./install.sh --uninstall
```

---

## Docker

Utiliser system-utilities dans un conteneur :

```bash
docker build -t system-utilities .
docker run -it system-utilities
```

---

## yt_download

Telecharger des cours (videos, playlists) ou des livres audio avec `yt-dlp` et `ffmpeg`.

### Dependances

- `yt-dlp`
- `ffmpeg`

Le script verifie leur presence au demarrage et s'arrete si l'un des deux est manquant :

```bash
sudo dnf install yt-dlp ffmpeg   # Fedora
sudo apt install yt-dlp ffmpeg   # Debian/Ubuntu
```

### Utilisation

```bash
yt_download
```

Flux interactif :

1. Coller l'URL du media (video, playlist ou livre audio).
2. Choisir le dossier cible (defaut : `~/Videos`, modifiable dans la configuration).
3. Choisir le format :
   - **1** : Video (meilleure qualite par defaut)
   - **2** : Video (choisir une qualite specifique via `yt-dlp -F`)
   - **3** : Audio uniquement (extraction MP3, qualite maximale)
4. Choisir d'executer en arriere-plan pour suivre la progression.

### Menu principal

1. **Nouveau telechargement**
2. **Reprendre** un telechargement inacheve (en cours / echoue)
3. **Suivre les telechargements en cours** (rafraichissement toutes les 2 s, `#` pour annuler proprement, `Q` pour quitter)
4. **Configuration** (preferences persistantes)
5. **Historique** complet
6. **Quitter**

### Suivi de progression

- Chaque telechargement lance en arriere-plan est journalise (`~/.local/share/yt_download/<n>.log`) avec son PID et son code de sortie.
- Vitesse, ETA et avancement sont affiches en direct. A la fin, une notification (`notify-send` ou son) signale le resultat.
- On peut lancer plusieurs telechargements simultanement et les suivre dans une meme vue.

### Preferences (~/.config/yt_download/config)

| Option | Description |
|--------|-------------|
| `DEFAULT_DIR` | Dossier de telechargement par defaut (`~/Videos`) |
| `DEFAULT_FORMAT` | Format du menu applique par defaut (1, 2 ou 3) |
| `RATE_LIMIT` | Limite de debit (`--limit-rate`, ex : `2M`, `500K`) |
| `USE_ARCHIVE` | Archive anti re-telechargement (`--download-archive`, dans `~/.local/share/yt_download/downloaded.txt`) |
| `SUBTITLES` / `SUBTITLE_LANGS` | Sous-titres pour les cours (`--write-subs --embed-subs`, langues ex : `fr,en`) |
| `CHAPTERS` | Chapitres integres (`--embed-chapters`, formats video) |
| `NOTIFY_END` | Notifier en fin de telechargement |
| `COOKIES_FILE` | Fichier cookies pour les contenus restreints (`--cookies`) |

### Playlists et conflits

- Les playlists sont rangees dans un sous-dossier au nom de la playlist, les fichiers gardent leur nom d'origine.
- En cas de fichier deja present, le script propose 3 solutions : ecraser, ignorer les fichiers existants, ou renommer avec un numero.

### Historique et reprise

- Chaque telechargement est journalise dans `~/.local/share/yt_download/history` (statut `en_cours`, `echoue` ou `termine`).
- Le menu permet de lister tous les telechargements et de reprendre ceux inacheves (en cours ou echoues) avec reprise des fichiers partiels.
- Les telechargements encore actifs en arriere-plan sont automatiquement exclus du menu de reprise pour eviter les doublons.

### Options

| Option | Description |
|--------|-------------|
| `--help` | Afficher l'aide |
| `--version` | Afficher la version |

---

## Contribution

1. Fork le depot
2. Creer une branche (`git checkout -b feature/ma-feature`)
3. Commit les changements (`git commit -m "Ajout de ..."`)
4. Push la branche (`git push origin feature/ma-feature`)
5. Ouvrir une Pull Request

## Licence

GPL v3 - Voir le fichier LICENSE
