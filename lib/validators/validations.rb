# coding: utf-8

module Validations

  class NotNullAmount < ActiveModel::Validator

    def validate(record)
      if record.debit == 0 && record.credit == 0
        record.errors[:credit] << 'ne peut être nul'
        record.errors[:debit] << 'ne peut être nul'
      end
    end

  end

end
