# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Faitesvoscomptes::Application.initialize!

# ne pas oublier de mettre en place un fichier .env avec les variables
# d'environnement nécessaires, en l'occurence 
# 
# DEVISE_SEC_KEY='123456789abcdef123...'
# MAIL_HOST='le domaine ou est hébergé le programme'
# MAIL_USER_NAME='l adresse mail de l expéditeur des mails'
# MAIL_PASSWORD='mot de passe du serveur de mail'
# MAIL_ADDRESS='adresse du serveur de mail'
# DOMAIN='le domaine'
# 
# Voir le fichier production.rb, devise.rb et user_incription.rb pour les 
# contextes où ces variables sont utilisées. 