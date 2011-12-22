# -*- encoding : utf-8 -*-

class BankAccount < ActiveRecord::Base
  belongs_to :organism
  has_many :check_deposits
  has_many :bank_extracts

  # Méthode qui donne le montant du dernier solde bancaire
  # par ordre de date
  #
  def last_bank_extract_sold
    self.bank_extracts.order(:end_date).last.end_sold
  rescue
    0
  end

  def last_bank_extract_day
    self.bank_extracts.order(:end_date).last.end_date
  rescue
    Date.today.beginning_of_month - 1
  end

 def not_pointed_lines
  ls=  Line.find_by_sql("SELECT id, narration, debit, credit, payment_mode, line_date
    FROM LINES WHERE (BANK_ACCOUNT_ID = #{self.id} AND ((PAYMENT_MODE != 'Chèque') or (credit < 0.001))) AND NOT EXISTS (SELECT * FROM BANK_EXTRACT_LINES WHERE LINE_ID = LINES.ID)")
    ls.map {|l| BankExtractLine.new(:line_id=>l.id)}

 end

 def not_pointed_check_deposits
    self.check_deposits.where('bank_extract_id IS NULL').map {|cd| BankExtractLine.new(:check_deposit_id=>cd.id)}
 end

 def lines_to_point
   self.not_pointed_lines +  self.not_pointed_check_deposits
 end

end
