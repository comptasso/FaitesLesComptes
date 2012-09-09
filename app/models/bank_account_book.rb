# coding: utf-8

require 'book.rb'

class BankAccountBook < Book
  has_one :bank_account, :foreign_key=>:book_id
end
