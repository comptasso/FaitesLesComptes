# coding: utf-8


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
DIRECT_BANK_PAYMENT_MODES = %w(CB Prélèvement Virement)


LIST_STATUS = %w(Association Entreprise)

# limites de validation
NAME_LENGTH_MIN = 3
NAME_LENGTH_MAX = 30
NAME_LENGTH_LIMITS = NAME_LENGTH_MIN..NAME_LENGTH_MAX

LONG_NAME_LENGTH_MAX = 90
LONG_NAME_LENGTH_LIMITS = NAME_LENGTH_MIN..LONG_NAME_LENGTH_MAX

MAX_COMMENT_LENGTH = 300



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
# version 0.7.0 : remise des bases dans une logique plus proche de Rails, étape vers l'utilisation de schemas
# version 0.7.1 : restrictions sur les caractères utilisés dans les saisies et passage à ruby 2.0
# version 0.7.3 : utlisation adaptée à sqlite3 et à postgresql
# version 0.8.0 : utilisation de devise pour la gestion des accès
# version 0.8.1 : mise en place d'une limite de 4 bases pour un user standard
# VERSION = '0.8.3RC' # l'inscription est désormais avec confirmation
# VERSION = '0.8.4RC' # remplacer les archives par un clone de la base
# VERSION = '0.8.5RC' # suppression du modèle Archive, action, routes, vues, tests corresondants
# VERSION = '0.9.0RC' # intégration du gem adhérent
# VERSION = '1.0.1RC' # mise en place des guides de saisie et corrections de bugs dans Transferts
# VERSION = '1.0.2RC' # correction bug - la liste des organismes n'était pas mise à jour après une suppression 
# VERSION = '1.1.0RC' # suppression de la table bank_extract_lines_lines et refonte du pointage des relevés 
# FLCVERSION = '1.1.1RC' # revu le javascript du pointage et suppression de facebox.js inutilisé 
FLCVERSION = '1.2.0RC' # folio et rubrik deviennent des éléments persistants. 