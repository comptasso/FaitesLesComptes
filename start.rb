# coding: utf-8

# fichier permettant le démarrage pour la version sous windows construite par
# le gem ocra.
#
# Ce script est appelé par le programme construit par ocra et permet un affichage
# au lancement.
#
# Le gem ocra a été patché pour faire que les bases ne soient pas écrasées par
# une nouvelle installation.En pratique cela est fait en ajoutant Flag: onlyifdoesntexist
# à la fin des lignes de la rubrique File qui comprennnent la chaine 'db/ocra'.
#
# Le fichier flc2.iss est assez simple
#
# La commande ocra utilisée pour la construction de l'installer est la suivante :
# ocra FaitesLesComptes\start.rb FaitesLesComptes --output FaitesLesComptes.exe --add-all-core --dll ssleay32-1.0.0-msvcrt.dll --dll sqlite3.dll --icon FaitesLesComptes/public/favicon.ico   --gemfile FaitesLesComptes/Gemfile --gem-full --no-dep-run --chdir-first --no-lzma --innosetup flc2.iss -- server mongrel -e ocra
#

require './config/initializers/all_constants.rb'

puts "Demarrage de FaitesLesComptes, version #{VERSION}, logiciel open-source de comptabilite de tresorerie et de comptabilite simplifiee"
puts ''
puts "=== lancement de ruby on rails - merci de patienter (de 30s a 1mn selon la vitesse de votre ordinateur)"
load 'script/rails'