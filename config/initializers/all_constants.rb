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

# REM_CHECK_ACCOUNT sert à créer et retrouver le compte remise chèque
# period.rem_check_account retourne ce compte ou le crée;
# Il est accountable car cela permet de le traiter à peu près comme un bank_account ou un cash.
# Notamment pour la fonction support.
# Il a donc has_many :accounts, :as=>accountable pour que accountable fonctionne
# et to_s qui retourne 'Chèque à l'encaissement'
# Par ailleurs accountable a été surchargé dans Account pour retourner une instance de RemCheckAccount 
# si le type est RemCheckAccount.
REM_CHECK_ACCOUNT = {number:'511', title:'Chèques à l\'encaissement', accountable_type:'RemCheckAccount', accountable_id:1}


# constante utilisée pour les éditions de pdf
NB_PER_PAGE_PORTRAIT = 40
NB_PER_PAGE_LANDSCAPE = 22

# constantes utilisées pour les lignes de saise
PAYMENT_MODES = %w(CB Chèque Espèces Prélèvement Virement)
BANK_PAYMENT_MODES = %w(CB Chèque Prélèvement Virement)

# constante utilisée dans le modèle Room pour trouver le chemin des bases organismes
# TODO à faire évoluer ultérieurement pour être au choix de l'utilisateur
PATH_TO_ORGANISMS = 'organisms'

LIST_STATUS = %w(Association Entreprise)

# 0.3 insertion du champ nickname dans BankAccount
# VERSION = '0.4'
# Version 0.5.0 insertion d'un champ status dans Organism
# refonte du modèle Transfer et travail sur la présentation du formulaire de Transfert
# Version 0.5.1 - correction des dates du formulaire contrôle de caisse
# version 0.6 : suppression du champ bank_extract_id des compta_lines ainsi que du champ type pour les bank_extract_lines.
# version 0.6.5 : corrections de bugs, page avertissant sur la version de IE
# version 0.6.6 : rebalayage ds fonctionnalités, nombreux petits bugs, gestion de la suppression des exercices
# version 0.6.7 : encore un grand coup de balayage des fonctionnalités et multiples corrections diverses.
# version 0.6.8 : couverture du programme par les test à 99,9%. Il reste 13 lignes non couvertes liées à l'environnement de test
VERSION = '0.6.8'