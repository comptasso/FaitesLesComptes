# coding: utf-8


# Validation qui limite le nombre de société à 4 maximum
class UpperLimitValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if record.user_id # le cas ou user_id est nil est traité par une autre validation
      u = record.user
      record.errors.add(attribute, :upper_limit) if u.rooms.count > 3

    end
  end

end