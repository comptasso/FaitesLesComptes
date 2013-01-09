# coding: utf-8

# Comme son nom l'indique ce validator vérifie que les champs date
# du modèle sont compris dans l'exercice.
#
# Le modèle doit avoir une méthode period qui renvoie l'exercice.
#
#
class WithinPeriodValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    unless  value.is_a?(Date)
      record.errors.add(attribute, :invalid_date)
      return
    end
    raise 'Le modèle doit répondre à la méthode period' unless record.respond_to?(:period)
    if p = record.period
      record.errors.add(attribute, :out_limits) unless value >= p.start_date && value <=p.close_date
    else
      record.errors.add(attribute, :no_period)
    end
  end

end
