# coding: utf-8

# TODO déplacer ceci dans un initializer

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

