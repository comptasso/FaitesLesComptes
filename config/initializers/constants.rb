# coding: utf-8

# Constantes utilisées par les fonctions restore et save
#
# TODO voir si encore utile après mise en place du gem apartment
#
# organism est traité à part car c'est le modèle mère de tous les autres et du coup, il est au singulier dans archive ou restore
# pour que l'archive fonctionne, il faut que le modèle organism puisse accéder à tous les autres modèles directement ou au travers de through
# ne pas oublier d'ajouter les nouveaux modèles en cas d'évolution de l'architecture de la base
# ne pas oublier de redémarrer le serveur en cas de modification de ce fichier
ORGANISM = ['organism']
MODELS = %w(period bank_account destination line bank_extract check_deposit cash cash_control book account nature bank_extract_line income_book outcome_book od_book transfer)
ORGMODELS = ORGANISM + MODELS

REM_CHECK_ACCOUNT = {number:'511', title:'Chèques à l\'encaissement'}


# constante utilisée pour les éditions de pdf
NB_PER_PAGE_PORTRAIT = 40
NB_PER_PAGE_LANDSCAPE = 22

# constantes utilisées pour les lignes de saise
PAYMENT_MODES = %w(CB Chèque Espèces Prélèvement Virement)
BANK_PAYMENT_MODES = %w(CB Chèque Prélèvement Virement)

# constante utilisée dans le modèle Room pour trouver le chemin des bases organismes
# TODO à faire évoluer ultérieurement pour être au choix de l'utilisateur
PATH_TO_ORGANISMS = 'organisms'

VERSION = 0.1