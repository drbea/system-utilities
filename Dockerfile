FROM ubuntu:22.04

# Mettre à jour et installer les dépendances
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    git \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Créer un utilisateur non-root
RUN useradd -m -s /bin/bash user
USER user
WORKDIR /home/user

# Copier system-utilities
COPY --chown=user:user . /home/user/system-utilities/

# Installer
RUN cd /home/user/system-utilities && bash install.sh --force

# Ajouter au PATH
ENV PATH="/home/user/.local/bin:${PATH}"

# Commande par défaut
CMD ["bash"]
