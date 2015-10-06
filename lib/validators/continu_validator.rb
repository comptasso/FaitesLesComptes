# coding: utf-8


# Validation qui indique que la numérotation doit être continue
class ContinuValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    dernier_numero = record.last_continuous_id
    record.errors.add(attribute, :not_continuous) if value != dernier_numero + 1
  end

end
