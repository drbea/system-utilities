# system-utilities

## 🚀 create_project.sh

Un script Bash universel pour créer rapidement des projets Python/Django avec :

Environnement virtuel .venv automatique

Support Django ou structure Python générique

Configuration .env avec SECRET_KEY et DATABASE_URL

Base de données : SQLite (par défaut), PostgreSQL ou MySQL/MariaDB

Initialisation Git + .gitignore complet

Makefile avec commandes utiles (setup, run, migrate, createsuperuser, …)

README + .env.example générés automatiquement

📦 Installation

Cloner le dépôt :
```bash
git clone https://github.com/drbea/system-utilities.git
# ou 
git clone git@github.com:drbea/system-utilities.git
cd system-utilities
chmod +x create_project.sh
```

▶️ Utilisation
1. Créer un projet Django
   ```bash
   ./create_project.sh --django mon_projet
   ```
2. Créer un projet Python générique
   ```bash
   ./create_project.sh mon_package
   ```
3. Créer un projet dans le dossier courant
   ```bash
   ./create_project.sh --django
   ```
5. ⚙️ Options disponibles
      | Option      | Description                                     |
      | ----------- | ----------------------------------------------- |
      | `--no-venv` | Ne pas créer d’environnement virtuel            |
      | `--no-git`  | Ne pas initialiser de dépôt Git                 |
      | `--django`  | Créer un projet Django (`src/config`)           |
      | `--db`      | Base de données : `sqlite`, `postgres`, `mysql` |
      | `--db-name` | Nom de la base (par défaut : `<project>_db`)    |
      | `--db-user` | Utilisateur DB (postgres/mysql)                 |
      | `--db-pass` | Mot de passe DB                                 |
      | `--yes`     | Mode non interactif (tout par défaut)           |
      | `--help`    | Affiche l’aide                                  |

7. 🗃️ Exemple d’utilisation avec PostgreSQL
   ```bash
   ./create_project.sh --django --db postgres --db-name blog_db --db-user bloguser --db-pass secret blog
   ```
   Cela va créer :
   Un projet Django dans src/config/
   Un fichier .env :
   ```
   DEBUG=True
   SECRET_KEY=xxxxxx
   DATABASE_URL=postgres://bloguser:secret@localhost:5432/blog_db
   ```
   📂 Structure générée
   Avec Django
   ```arduino
   mon_projet/
      ├── .venv/
      ├── src/
      │   └── config/
      ├── tests/
      ├── docs/
      ├── .env
      ├── .env.example
      ├── requirements.txt
      ├── Makefile
      ├── .gitignore
      └── README.md
   ```
   Projet Python générique
   ```arduino
      mon_package/
            ├── .venv/
            ├── src/
            │   └── mon_package/
            │       └── __init__.py
            ├── tests/
            ├── docs/
            ├── .env
            ├── .env.example
            ├── requirements.txt
            ├── Makefile
            ├── .gitignore
            └── README.md
   ```
   🔧 Makefile inclus
      | Commande               | Description                              |
      | ---------------------- | ---------------------------------------- |
      | `make setup`           | Crée `.venv` et installe les dépendances |
      | `make run`             | Lance le serveur Django                  |
      | `make migrate`         | Exécute les migrations Django            |
      | `make createsuperuser` | Crée un super utilisateur Django         |
      | `make test`            | Lance les tests unitaires                |
      | `make freeze`          | Met à jour `requirements.txt`            |
      | `make clean`           | Nettoie le projet                        |

9. 🤝 Contribution

Fork le repo 🍴

- Crée ta branche (```bash git checkout -b feature/ma-feature```)

Commit tes changements (```bash git commit -m "Ajout nouvelle option"```)

Push ta branche (```bash git push origin feature/ma-feature```)

Ouvre une Pull Request 🚀
10. ----
   
