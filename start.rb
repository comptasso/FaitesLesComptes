# coding: utf-8

# fichier permettant le démarrage pour la version sous windows construite par
# le gem ocra.

require File.expand_path('config/initializers/constants.rb', ENV['OCRA_EXECUTABLE']) if ENV['OCRA_EXECUTABLE']

puts "Demarrage de FaitesLesComptes version #{VERSION}, logiciel open-source de comptabilite simplifiee"
puts ''
puts "=== lancement de ruby on rails - merci de patienter (de 30s a 1mn selon la vitesse de votre ordinateur)"
load 'script/rails'