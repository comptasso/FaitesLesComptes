# coding: utf-8


# REM_CHECK_ACCOUNT sert à créer retrouver le compte remise chèque
# 
# TODO A revoir ???
# Il a donc has_many :accounts, :as=>accountable pour que accountable fonctionne
# et to_s qui retourne 'Chèque à l'encaissement'
# Par ailleurs accountable a été surchargé dans Account pour retourner une instance de RemCheckAccount 
# si le type est RemCheckAccount.
REM_CHECK_ACCOUNT = {number:'511', title:'Chèques à l\'encaissement'}.freeze
RESULT_ACCOUNT = '12'


# constante utilisée pour les éditions de pdf
NB_PER_PAGE_PORTRAIT = 40
NB_PER_PAGE_LANDSCAPE = 22

# constantes utilisées pour les lignes de saise
PAYMENT_MODES = %w(CB Chèque Espèces Prélèvement Virement)
BANK_PAYMENT_MODES = %w(CB Chèque Prélèvement Virement)
DIRECT_BANK_PAYMENT_MODES = %w(CB Prélèvement Virement)


LIST_STATUS = ['Association', 'Comité d\'entreprise', 'Entreprise' ]

# limites de validation
NAME_LENGTH_MIN = 3
NAME_LENGTH_MAX = 30
NAME_LENGTH_LIMITS = NAME_LENGTH_MIN..NAME_LENGTH_MAX

MEDIUM_NAME_LENGTH_MAX = 60

LONG_NAME_LENGTH_MAX = 90
LONG_NAME_LENGTH_LIMITS = NAME_LENGTH_MIN..LONG_NAME_LENGTH_MAX

MAX_COMMENT_LENGTH = 300

# plan comptable
RACINE_BANK = '512'
RACINE_CASH = '53'



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
# VERSION = '0.8.4RC' # remplacé les archives par un clone de la base
# VERSION = '0.8.5RC' # suppression du modèle Archive, action, routes, vues, tests corresondants
# VERSION = '0.9.0RC' # intégration du gem adhérent
# VERSION = '1.0.1RC' # mise en place des guides de saisie et corrections de bugs dans Transferts
# VERSION = '1.0.2RC' # correction bug - la liste des organismes n'était pas mise à jour après une suppression 
# VERSION = '1.1.0RC' # suppression de la table bank_extract_lines_lines et refonte du pointage des relevés 
# FLCVERSION = '1.1.1RC' # revu le javascript du pointage et suppression de facebox.js inutilisé 
# FLCVERSION = '1.2.0RC' # folio et rubrik deviennent des éléments persistants. 
# FLCVERSION = '1.2.1RC' # Mise en place d'une vue des écritures non pointées et travail sur le solde instantané 
# FLCVERSION = '1.2.2.RC' # Mise en place d'une vue des écritures du compte bancaire par mois 
# FLCVERSION = '1.2.3.RC' # "Export de la vue des écritures du compte bancaire en csv et pdf"
# FLCVERSION = '1.2.4.RC' # "Correction bug sur mise à jour transfert et sur menu des views bottom'
# FLCVERSION = '1.2.5.RC' # "Refonte complète des éditions pdf'
# FLCVERSION = '1.3.0.RC' # "Introduction des delayed jobs pour les pdf et accélération des constructions des bilans'
# FLCVERSION = '1.3.2.RC' # Mise en place du fichier des écritures comptables
# FLCVERSION = '1.3.3.RC' # Refactorisation de l'édition d'une balance qui peut donc se passer de delayed jobs
# FLCVERSION = '1.4.0RC' # Mise en place des abonnements
# FLCVERSION = '1.4.1RC' # Préparation pour les CE. Modifications de la logique des natures qui ont 
# maintenant également belongs_to book.
# FLCVERSION = '1.4.2RC' # Version sectorisée pour les CE
# FLCVERSION = '1.4.3RC' # Refonte des graphiques pour accélérer l'affichage du DashBoard
# FLCVERSION = '1.4.4RC' # revision des plans comptables et nomenclatures
# FLCVERSION = '1.4.5RC' # mise en place d un modèle Holder pour avoir des status owner et guest
# FLCVERSION = '1.4.6RC' # les noms de bases de données sont suffixées par un timestamp
# FLCVERSION = '1.4.7RC' # retrait de la contrainte unique sur continuous_id (pour pb de verrouillage)
# FLCVERSION = '1.4.8RC' # ajout de written by suite à Holder
# FLCVERSION = '1.4.9RC' # peristence de check_nomenclature
# FLCVERSION = '1.4.10RC' # seuls les comptes used sont reproduits lors de la créa d'un nouvel exercice
# FLCVERSION = '1.4.11RC' # les valeurs futures ne sont plus affichées dans les graphes
# FLCVERSION = '1.4.12RC' # mise en place des exports pour les journaux
# FLCVERSION = '1.4.13RC' # modification de destination en activité (dans les vues, pas dans les tables)
# FLCVERSION = '1.4.14RC' # les abonnements sont passés dans la vue principale avec du javascript
# FLCVERSION = '1.5.0RC' # Mise en place des importations de relevés bancaires
# FLCVERSION = '1.5.1RC' # Modification du menu Natures et de l'affichage index
# FLCVERSION = '1.5.2RC' # Retouche vue de désinscription et automatisation message de bienvenue'
# FLCVERSION = '1.5.3RC' # DelayedJob pour remplir les tables d'un nouvelle exercice
# FLCVERSION = '1.5.4RC' # Les writings ne peuvent être écrites que si l'ex est ouvert
# FLCVERSION = '1.5.5RC' # Création d'une request en SQL pour affichage plus rapide des writings
# FLCVERSION = '1.5.6RC' # Modification des variables d'environnement pour une install autonome
# FLCVERSION = '1.5.7RC' # Passage en delayed::job des envois de mails
# FLCVERSION = '1.6.0RC' # Passage en persistant des valeurs des rubriques
# FLCVERSION = '1.6.1RC' # NomenclatureChecker pour le contrôle des nomenclatures
# FLCVERSION = '1.6.2RC' # Création d'une balance analytique
# FLCVERSION = '1.6.3RC' # Correction bug Listing#show si chngt d'exercice
# FLCVERSION = '1.6.4RC' # accélération des pdf de Listing et Grand Livre
# FLCVERSION = '1.6.5RC' # mise en place d'un recu pour le gem adhérent
FLCVERSION = '1.6.6RC' # correction bug sur form in_out_writings