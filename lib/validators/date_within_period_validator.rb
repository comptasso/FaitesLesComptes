# coding: utf-8

# Comme son nom l'indique ce validator vérifie que la date de l'écriture correspond à un exercice
# Il faut trouver les exercice à partir de la chaine book -> organism
# Donc on commence par tester la capacité à trouver l'organism puis on peut faire les tests
#
class DateWithinPeriodValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "Date invalide" unless value.is_a?(Date)
    p = record.period
    record.errors[:period] << "Exercice manquant" unless p
    if value.is_a?(Date) && p
      unless value >= p.start_date && value <=p.close_date
      Rails.logger.warn "Date hors limite dans la création d'une balance"
      record.errors[attribute] << "Date hors limite"
     end
    end
  end
end
