# coding: utf-8


# sans accent pour éviter les problèmes d'affichage sous windows
if Rails.env == 'ocra'
  puts "=== demarrage du serveur"
  puts "Vous pouvez maintenant utiliser votre navigateur prefere (Firefox, Chrome, Internet Explorer,...) a l'adresse localhost:3000."
  puts ''
  puts "Laisser cette fenêtre ouverte pendant toute la durée d'utilisation de FaitesLesComptes"
  puts "Lorsque vous avez fini, déconnectez vous dans le navigateur"
  puts "Puis Ctrl + C dans cette fenêtre et quitter le programme"
  puts ''
  puts "Vos retours nous intéressent, contactez nous à expert@faiteslescomptes.fr"
else
  puts 'Bienvenue sur FaitesLesComptes, le logiciel open-source de comptabilité de trésorerie'
end