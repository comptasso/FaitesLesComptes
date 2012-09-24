# coding: utf-8

class TwoComptaLinesMinimumValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.compta_lines.count < 2
      record.errors[:base] << "Une écriture doit avoir au moins deux lignes"
      return
    end
  end
end
