# coding: utf-8

 # validateur qui empeche de remettre une valeur true à false
  # utile pour les modèles qui ont un champ booleen de validation
  class CantBecomeFalseValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors[attribute] << "Impossible de dévalider #{attribute}" if value==false && record.changed_attributes[attribute.to_s]
    end
  end
