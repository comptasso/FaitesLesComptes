# coding: utf-8

# La classe StripCallback est utilisée pour enlevere les espaces blancs 
# au début ou la fin d'une chaîne. 
# 
# Cela évite de ne pas comprendre pourquoi des caractères sont non autorisés
# dans les saisies alors qu'il ne s'agit que d'un espace blanc à la fin de la chaîne.
#
module Jccallbacks

class StripCallback 

  def initialize(attributes_to_strip)
    @attributes_to_strip = attributes_to_strip
  end

  def before_validation(model)
    @attributes_to_strip.each do |field|
      model[field].strip! if model[field]
    end
  end
end

end

class ActiveRecord::Base

  # méthode permettant d'ajouter un nettoyage de champs avant la validation
  # 
  # il suffit dans un modèle d'indiquer strip_before_validation(:title, :comment)
  #
  def self.strip_before_validation(*attributes_to_strip)
    strip_cb = Jccallbacks::StripCallback.new(attributes_to_strip)
    before_validation strip_cb
  end
end

