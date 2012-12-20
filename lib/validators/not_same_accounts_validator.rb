# coding: utf-8

class NotSameAccountsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    n = record.compta_lines.map {|l| l.account_id}
    record.errors[:base] << "Les comptes doivent être différents" if n.size != n.uniq.size
  end
end
