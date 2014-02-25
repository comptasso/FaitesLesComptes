# coding: utf-8


# Validation qui limite le nombre de société à 4 maximum
class UpperLimitValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if record.owner # le cas ou user_id est nil est traité par une autre validation
      u = record.owner
      record.errors.add(attribute, :upper_limit) unless u.allowed_to_create_room?
    end
  end

end