# coding: utf-8


# vérifie que débit et crédit ne sont pas remplis simultanément
class NotBothAmountsValidator < ActiveModel::Validator

  def validate(record)
    if record.debit != 0 && record.credit != 0
      record.errors[:credit] << 'debit et crédit sur une même ligne'
      record.errors[:debit] << 'debit et crédit sur une même ligne'
    end
  end

end

