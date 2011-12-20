# -*- encoding : utf-8 -*-

class BankExtractLine < ActiveRecord::Base
  belongs_to :bank_extract
  belongs_to :check_deposit
  belongs_to :line

  attr_reader :date, :payment, :narration, :debit, :credit

  after_initialize :prepare_datas

  def prepare_datas
    if self.line_id != nil
      l=self.line
      @date = l.line_date
      @debit= l.debit
      @credit=l.credit
      @payment=l.payment_mode
      @narration = l.narration
    elsif self.check_deposit_id != nil
      cd=self.check_deposit
      @date=cd.deposit_date
      @debit=0
      @credit=cd.total
      @narration = 'remise de cheques'
      @payment = 'Chèques'
    end
    
  end
end
