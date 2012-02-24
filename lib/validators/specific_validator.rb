# -*- encoding : utf-8 -*-
# Le fichier specific_validator est destinée à contenir les validateurs spécifiques qui
# sont utilisés par différents modèles




  # validateur qui empeche de remettre une valeur true à false
  # utile pour les modèles qui ont un champ booleen de validation 
  class CantBecomeFalseValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors[attribute] << "Impossible de dévalider #{attribute}" if value==false && record.changed_attributes[attribute.to_s]
    end
  end

  # permet de bloquer l'édition de tous les champs sauf validated lorsque validated est à true
  # s'utilise en mettant validates :validated, :cant_edit_after_validation=>true
  class CantEditAfterValidationValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
    if (record.validated? == true)  && (record.changed_attributes['validated']== nil)
      record.attributes.each do |attr|
       record.errors[attribute] << "Impossible de modifier #{attr} car #{record} est validé" if record.changed_attributes[attr.first]
    end
    end

    end
  end

  # très voisin du précédent vaidator mais permet de cibler un seul champ#
  # s'utilise en faisant par exemple validates :narration, :cant_edit_field_after_validation=>true
  class CantEditFiledAfterValidationValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if (record.validated? == true)  && (record.changed_attributes['validated']== nil)
         record.errors[attribute] << "Impossible de modifier #{attribute} car #{record} est validé" if record.changed_attributes[attribute.to_s]
      end
    end
  end


  
