# coding: utf-8

# Comme son nom l'indique ce validator vérifie que la date de l'écriture correspond à un exercice
# 
#
class MustBelongToPeriodValidator < ActiveModel::EachValidator
 
  def validate_each(record, attribute, value)
    raise 'Le modèle doit répondre à la méthode period' unless record.respond_to?(:period)
    record.errors[attribute] << "Impossible d'enregistrer la ligne car la date n'appartient à aucun exercice" unless record.period
  end

end

