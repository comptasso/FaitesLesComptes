# coding: utf-8


# vérifie que débit et crédit ne sont pas nuls simultanément
class NotNullAmountsValidator < ActiveModel::Validator

  def validate(record)
    if record.debit == 0 && record.credit == 0
      record.errors[:credit] << 'ne peut être nul'
      record.errors[:debit] << 'ne peut être nul'
    end
  end

end
