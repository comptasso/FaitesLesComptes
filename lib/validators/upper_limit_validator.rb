# coding: utf-8

class UpperLimitValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    u = record.user
    record.errors.add(attribute, :upper_limit) if u.rooms.count > 3
  end

end