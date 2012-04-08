# coding: utf-8
# 
# le validateur CantChangeValidator est utilisé pour interdire la modification d'un attribut
# Exemple d'utilisation  : pour valider la présence, le format et l'interdiction de changer le numéro
# validates :acc_number, :presence=>true, :format=>{:with=>/\A[1-9]{1}[0-9]{1}[A-Z0-9]{0,8}\Z/}, :cant_change=>true
class CantChangeValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors[attribute] << "Impossible de modifier #{attribute}" if record.changed_attributes[attribute.to_s]
    end
  end