import subprocess
import os
import sys

"""
Ce script Python permet d'éteindre l'ordinateur sous Fedora Linux.
Il demande une confirmation à l'utilisateur avant de procéder à l'arrêt.

Auteur: PEVE BEAVOGUI
Fichier: shutdown_script.py
"""

def shutdown():
    """
    Demande à l'utilisateur s'il est sûr de vouloir éteindre l'ordinateur.
    Si l'utilisateur répond 'o' (oui), la commande 'sudo shutdown now' est exécutée
    pour procéder à l'arrêt immédiat du système. Cette commande nécessite
    généralement des privilèges administrateur (sudo).

    Si l'utilisateur répond 'n' (non), l'opération est annulée.
    Si l'utilisateur entre une autre valeur, un message d'erreur est affiché.

    En cas d'erreur lors de l'exécution de la commande d'arrêt (par exemple,
    si 'sudo' requiert un mot de passe et qu'il n'est pas fourni), un message
    d'erreur est affiché.
    """
    while True:
        entry = input("\tÊtes-vous sûr de vouloir éteindre votre ordinateur ?\n\tTapez 'o' pour Oui ou 'n' pour Non : ")
        if entry.lower() == "o":
            print("Extinction en cours...")
            try:
                # Commande pour éteindre sous Fedora Linux (nécessite généralement sudo)
                subprocess.run(["sudo", "shutdown", "now"], check=True)
                print("À bientôt !")
                break
            except subprocess.CalledProcessError as e:
                print(f"Erreur lors de l'arrêt : {e}")
                print("Assurez-vous d'avoir les droits d'administrateur (sudo) pour exécuter cette commande.")
                break
        elif entry.lower() == "n":
            print("Opération annulée.")
            break
        else:
            print("Entrée invalide. Veuillez taper 'o' ou 'n'.")



if __name__ == "__main__":
    shutdown()

