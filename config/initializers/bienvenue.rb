# coding: utf-8

# Ce fichier fait partie des initializers et donc est affiché dans la console lors du lancement.
#
# ocra est l'environnement créé pour les applications autonome sous windows. Cela permet d'avoir
# les informations sur l'utilisation du programme.

# car besoin de la constante VERSION
# require File.join(Rails.root, 'config/initializers/constants.rb')

# sans accent pour éviter les problèmes d'affichage sous windows
if Rails.env == 'ocra'
  puts "=== demarrage du serveur version #{FLCVERSION}"
  puts "Vous pouvez maintenant utiliser votre navigateur prefere (Firefox, Chrome, Internet Explorer,...) a l'adresse http://localhost:3000."
  puts ''
  puts "Laisser cette fenetre ouverte pendant toute la duree d'utilisation de FaitesLesComptes"
  puts "Lorsque vous avez fini, deconnectez vous dans le navigateur"
  puts "Puis Ctrl + C dans cette fenetre et quitter le programme"
  puts ''
  puts "Vos retours nous interessent, contactez nous a expert@faiteslescomptes.fr"
else
  puts "Bienvenue sur FaitesLesComptes version #{FLCVERSION}, logiciel open-source de comptabilite de tresorerie"
end