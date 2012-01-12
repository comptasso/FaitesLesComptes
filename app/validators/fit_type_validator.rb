# coding: utf-8
class FitTypeValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    r = record.income_outcome
    a=Account.find_by_id(value).number[0] # premier chiffre de la chaîne
    if ((r==true && a=='6') || (r==false && a=='7'))
      record.errors[attribute] << "La nature doit être associée à un compte de même type (recettes ou dépenses)"
    end
  end
end