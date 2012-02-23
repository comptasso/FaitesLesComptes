# coding: utf-8

class MustBelongToPeriodValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    o= record.book.organism
    unless o.find_period(value)
      Rails.logger.warn "Record Line invalide - line_date n'appartient à aucun exercice"
      record.errors[attribute] << "Impossible d'enregistrer la ligne car la date n'appartient à aucun exercice"
     end
  end
end
