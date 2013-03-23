# coding: utf-8

# fichier permettant le démarrage pour la version sous windows construite par
# le gem ocra.

require 'config/initializers/constants'

puts "Demarrage de FaitesLesComptes version #{VERSION}, logiciel open-source de comptabilite simplifiee"
puts ''
puts "=== lancement de ruby on rails - merci de patienter (de 30s a 1mn selon la vitesse de votre ordinateur)"
load 'script/rails'