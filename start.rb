# coding: utf-8

# fichier permettant le démarrage pour la version sous windows construite par
# le gem ocra.

require 'config/initializers/all_constants'

puts "Demarrage de FaitesLesComptes, verssion #{VERSION}, logiciel open-source de comptabilite de trésorerie et de comptabilité simplifiee"
puts ''
puts "=== lancement de ruby on rails - merci de patienter (de 30s a 1mn selon la vitesse de votre ordinateur)"
load 'script/rails'