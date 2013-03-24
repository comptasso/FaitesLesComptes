# coding: utf-8

 # validateur qui empeche de remettre une valeur false à true
  # utile pour les modèles qui ont un champ booleen de validation.
  #
  # Exemple d'utilisation (venant de Period)
  # validates :open, :cant_become_true=>true
  class CantBecomeTrueValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors[attribute] << "Impossible de revalider #{attribute}" if !record.changed_attributes[attribute.to_s].nil? && value == true
    end
  end
