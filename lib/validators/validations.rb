# coding: utf-8

module Validations
  class NotNullAmount < ActiveModel::Validator
  def validate(record)
    if record.debit == 0 && record.credit == 0
      record.errors[:base] << 'Débit et crédit ne peuvent être tous les deux nuls!'
    end
  end
end


end
