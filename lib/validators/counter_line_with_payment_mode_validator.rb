# coding: utf-8

class CounterLineWithPaymentModeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    cl = record.counter_line
    puts cl.inspect
    if cl.payment_mode.blank?
      cl.errors.add(:payment_mode, :blank)
      record.errors.add(attribute, 'erreur sur la counter_line')
      return
    end
    unless cl.payment_mode.in?(PAYMENT_MODES)
      cl.errors.add(:payment_mode, :not_accepted)
      record.errors.add(attribute, 'erreur sur la counter_line')
    end
  end
end