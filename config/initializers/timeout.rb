

# config/initializers/timeout.rb
# 
# lignes venant de la page heroku/rails-unicorn
# Rack::Timeout.timeout = 15  # seconds


# Ligne ajoutée en mars 2015, suite à problèmes de test pour les features
# utilisant javascript. Voir issue 55 sur Github/heroku/rack-timeout
Rack::Timeout.timeout = (Rails.env.test? ? 0 : 20)
