# coding: utf-8

require 'book.rb'

class CashBook < Book
  has_one :cash, :foreign_key=>:book_id 
end
