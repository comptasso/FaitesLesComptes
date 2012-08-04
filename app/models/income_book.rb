# coding: utf-8

require 'book.rb'

class IncomeBook < Book
   # les chèques en attente de remise en banque
  has_many :pending_checks,
    :class_name=>'Line',
    :conditions=>'payment_mode = "Chèque" and credit > 0 and check_deposit_id IS NULL'
  
end
