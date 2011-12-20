# -*- encoding : utf-8 -*-

class BankExtractLine < ActiveRecord::Base
  belongs_to :bank_extract
  belongs_to :check_deposit
  belongs_to :line

  attr_reader :date, :payment, :narration, :debit, :credit

  def after_initialize
    if self.line_id
      l=self.line
      @date = l.line_date
      @debit= l.line.debit
      @credit=l.line.credit
      @payment=l.line.payment
      @narration = l.line.narration
    elsif self.check_deposit_id
      cd=self.check_deposit_id
      @date=cd.deposit_date
      @debit=0
      @credit=cd.total
      @narration = 'remise de cheques'
      @payment = 'Chèques'
    end
    
  end
end
