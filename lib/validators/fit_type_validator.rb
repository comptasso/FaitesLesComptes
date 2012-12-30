# coding: utf-8

# Ce validator vérifie que la nature et le compte comptable sont cohérent
# Une nature de type recettes doit correspondre à un compte de classe 7
# Une nature de type dépenses doit correspondre à un compte de classe 6
#
class FitTypeValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if value
      r = record.income_outcome
      a = Account.find_by_id(value).number[0] # premier chiffre de la chaîne
      if ((r == true && a != '7') || (r == false && a != '6'))
        record.errors[attribute] << "La nature doit être associée à un compte de même type (recettes ou dépenses)"
      end
    end
  end
end