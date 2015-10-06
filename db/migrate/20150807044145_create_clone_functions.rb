class CreateCloneFunctions < ActiveRecord::Migration
  def up
    # Crée les fonctions de recopie des tables. Voir
    # le modèle Utilities::Cloner
    Utilities::Cloner.create_clone_functions
  end
end
