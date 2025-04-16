#!/bin/bash

# Vérification des droits root
if [ "$EUID" -ne 0 ]; then
  echo "⚠️  Ce script doit être exécuté avec les droits superutilisateur (sudo ou root)."
  exit 1
fi

echo "==========================="
echo "==== Mise à jour du système actuel ===="
echo "==========================="
dnf upgrade --refresh -y

echo
echo "==========================="
echo "==== Installation de l'outil dnf-plugin-system-upgrade ===="
echo "==========================="
dnf install -y dnf-plugin-system-upgrade

echo
echo "==========================="
echo "==== Détection de la version actuelle de Fedora ===="
echo "==========================="
CURRENT_VERSION=$(rpm -E %fedora)
NEXT_VERSION=$((CURRENT_VERSION + 1))
echo "Version actuelle : Fedora $CURRENT_VERSION"
echo "Mise à niveau vers : Fedora $NEXT_VERSION"

echo
echo "==========================="
echo "==== Téléchargement des paquets pour Fedora $NEXT_VERSION ===="
echo "==========================="
dnf system-upgrade download --releasever=$NEXT_VERSION --allowerasing -y

echo
echo "==========================="
echo "==== Redémarrage pour lancer la mise à niveau vers Fedora $NEXT_VERSION ===="
echo "==========================="
dnf system-upgrade reboot
