


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
# FLCVERSION = '1.6.6RC' # correction bug sur form in_out_writings
# FLCVERSION = '1.6.7RC' # accélératin vue Room#index
# FLCVERSION = '1.6.8RC' # accélératin vue pointage des comptes bancaires
# FLCVERSION = '1.6.9RC' # accélératin listing et refonte pdf listing et gd livre
# FLCVERSION = '1.6.10RC' # Passage à Rails 3.2.20 et conseils dans les vues in_out_lines
# FLCVERSION = '1.6.11RC' # info sur num° de pièce pour les remises de chèques
# FLCVERSION = '1.7.0RC' # sectorisation des numéros de comptes
# FLCVERSION = '1.7.1RC' # changer la banque d'une remise de chèque est possible
# FLCVERSION = '1.7.2RC' # mise en place d'un champ used pour les destinations
# FLCVERSION = '1.7.3RC' # correction de 3 bugs (nom trop long, cash_line vers compta et listing#to_csv)
# FLCVERSION = '1.7.4RC' # correction d'1 bug sur le pointage bancaire à la cloture
# FLCVERSION = '1.9.0RC' # passage à Rails 4e
# FLCVERSION = '1.9.1RC' # dernières corrections Rails 4
# FLCVERSION = '1.9.2RC' # réaffichage des soldes sur listing, accélération vues compta, nettoyage css
# FLCVERSION = '1.9.3RC' # before_destroy pour Account et modif vue index des comptes
# FLCVERSION = '1.9.4RC' # précompilation des assets en local pour accélération heroku
# FLCVERSION = '1.10.0RC' # champ comment dans payment pour servir de libellé
# FLCVERSION = '1.11.0RC' # champ siren et code postal dans organism
# FLCVERSION = '1.11.1RC' # passage à ruby 2.2.1
# FLCVERSION = '1.11.2RC' # Guard plus ordre des exercices, et autres mineures
# FLCVERSION = '1.11.3RC' # v 0.2.8 gem Adherent vue index et export csv des membres
# FLCVERSION = '1.11.4RC' # Mise en place css media print
# FLCVERSION = '1.11.5RC' # Gestion des adhérents qui seraient supprimés
# FLCVERSION = '1.11.6RC' # Mise à jour de Nature lignes verrouillées et gestion masques si changement de nom
# FLCVERSION = '1.11.7RC' # Passage au serveur Puma à la place de Unicorn
# FLCVERSION = '1.11.8RC' # Secteur commun pour les CE qui n'ont qu'un compte bancaire
# FLCVERSION = '1.11.9RC' # Accélération des stats Natures
# FLCVERSION = '1.11.10RC' # Suppression de 2 link_to_function (Compta::Writing new et edit)
# FLCVERSION = '1.11.11RC' # Mise en place des statistiques par activités/destinations
# FLCVERSION = '1.11.12RC' # Passage à Rails 4.1
# FLCVERSION = '1.11.13RC' # Correction bug sur remise de chèques pour les banques en secteur Commun
# FLCVERSION = '1.12.0RC' # mise en place de date_piece pour le FEC
# FLCVERSION = '1.12.1RC' # refonte des états suite réglements ANC pour les CE.
# FLCVERSION = '1.12.2RC' # documents corrects même si un compte n'existe pas dans l'exercice précédent
# FLCVERSION = '1.12.3RC' # Accès au module Compta même lorsque l'exercice est clos
# FLCVERSION = '1.12.4RC' # Quand on édite un Transfert, on revient vers le bon mois
# FLCVERSION = '1.12.5RC' # Les comptes de bilan prennent en compte le report de l'exercice précédent non clos
# FLCVERSION = '1.13.0RC' # Mise en place de piece_number pour les Writings
# FLCVERSION = '1.13.1RC' # Suppression des tables lines et listings réapparues suite à une fusion
# FLCVERSION = '1.13.2RC' # Correction de l'affichage des totaux pour les Caisses
# FLCVERSION = '1.13.3RC' # Corr. affichage stats par activité si tte écritures affectée
# FLCVERSION = '1.13.4RC' # Passage à Ruby 2.2.2
# FLCVERSION = '1.14.0RC' # Passage à une version sans schéma
# FLCVERSION = '1.14.1RC' # Adherent 0.3.4 et include ModalsForm dans 2 Helpers
# FLCVERSION = '1.14.2RC' # Un paiement sans adhérent peut être supprimé + correction Observer
# FLCVERSION = '1.14.3RC' # Amélioration module Adhérent (rapidité, icone nb_supprimer)
# FLCVERSION = '1.14.4RC' # Les banques et caisses sont ordonnées par leur id
# FLCVERSION = '1.14.5RC' # Refactorisation des bank_extract_lines et démarrage des écritures à 1
# FLCVERSION = '1.14.6RC' # Correction lines_to_point affichage piece_number et non id
# FLCVERSION = '1.14.7RC' # Correction bug affichage natures si update d'une in_out_writing échoue
# FLCVERSION = '1.14.8RC' # edit nature sait afficher le compte associé
FLCVERSION = '1.14.9RC' # Nouveau plan comptable pour les CE conforme réglement ANC
