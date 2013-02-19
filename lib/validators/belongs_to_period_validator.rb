# coding: utf-8

# BelongsToPeriodValidator vérifie que le champ est cohérent avec l'exercice
# Ceci est utile pour le champ nature_id et pour account_id qui sont des champs de
# compta_line et qui doivent être cohérent avec l'exercice donc avec la date de l'écriture.
#
# On garde donc le radical du champ nature et account et on vérifie que
# l'exercice auquel ils appartiennent comprend bien la date de l'écriture.
#
# Voir également WithinPeriodValidator pour vérifier que les dates sont dans les limites de l'exercice
# et NestedPeriodCoherent pour les champs nature_id et account_id des compta_lines vis à vis de Writing.
#
class BelongsToPeriodValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    attr = attribute.to_s.split('_').first.to_sym # pour ne garder que nature ou account et non nature_id
    if record.writing && record.writing.date.is_a?(Date)
      d = record.writing.date
      pid = record.writing.book.organism.find_period(d).id rescue nil 

      record.errors[attr] << "N'appartient pas à l'exercice comprenant #{I18n::l d}" if record.send(attr) && record.send(attr).period.id != pid


      end
    end
end
