# coding: utf-8

class ExactlyTwoComptaLinesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[:base] << "Une écriture doit avoir au moins deux lignes" if record.compta_lines.size != 2
  end
end
