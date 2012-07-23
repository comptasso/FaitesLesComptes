# coding: utf-8

# TODO vérifier s'il est utilisé car je pense que maintenant le champ est locked et non validated
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
