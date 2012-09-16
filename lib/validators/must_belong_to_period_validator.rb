# coding: utf-8

# Comme son nom l'indique ce validator vérifie que la date de l'écriture correspond à un exercice
# Il faut trouver les exercice à partir de la chaine book -> organism
# Donc on commence par tester la capacité à trouver l'organism puis on peut faire les tests
#
# TODO réécrire en se passant de Book puisqu'il y a maintenant un seul organisme par base de données
#
class MustBelongToPeriodValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless record.book
      record.errors[attribute] << "Incapable de trouver un exercice car impossible de déterminer l'organisme"
      return
    end
    o = record.book.organism
  
    if value.is_a?(Date)
    unless o.find_period(value)
      Rails.logger.warn "Record Line invalide - line_date n'appartient à aucun exercice"
      record.errors[attribute] << "Impossible d'enregistrer la ligne car la date n'appartient à aucun exercice"
     end
    end
  end
end

