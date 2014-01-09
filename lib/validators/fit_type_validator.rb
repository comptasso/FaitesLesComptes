# coding: utf-8

# Ce validator vérifie que la nature et le compte comptable sont cohérent
# Une nature appartenant à un livre de recettes doit correspondre à un compte de classe 7
# Une nature appartenant à un livre de dépenses doit correspondre à un compte de classe 6
#
class FitTypeValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    r = record.book.type rescue nil
    a = Account.find_by_id(value)
    if a && r
      account_classe = a.number[0] # premier chiffre de la chaîne
      if ((r == 'IncomeBook' && account_classe != '7') || (r == 'OutcomeBook' && account_classe != '6'))
        record.errors.add(attribute, :misfit, :income_outcome=>record.in_out_to_s, :account_classe=>account_classe)
      end
    end
  end
end