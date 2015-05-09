# config/initializers/timeout.rb
# 
# lignes venant de la page heroku/rails-unicorn
# j'ai ajouté le if car je ne charge pas Rack::Timeout pour les environnements
# de test et de développement

unless Rails.env.test? || Rails.env.development?
  Rack::Timeout.timeout = 20  # seconds
end


