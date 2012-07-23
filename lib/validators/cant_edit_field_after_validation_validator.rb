# -*- encoding : utf-8 -*-
  #
  # très voisin de cant edit validator mais permet de cibler un seul champ 
  # s'utilise en faisant par exemple validates :narration, :cant_edit_field_after_validation=>true
  class CantEditFieldAfterValidationValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if (record.validated? == true)  && (record.changed_attributes['validated']== nil)
         record.errors[attribute] << "Impossible de modifier #{attribute} car #{record} est validé" if record.changed_attributes[attribute.to_s]
      end
    end
  end


  
