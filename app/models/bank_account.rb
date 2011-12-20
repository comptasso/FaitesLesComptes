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
    Line.find_by_sql("SELECT id, narration, debit, credit, payment_mode
    FROM LINES WHERE (BANK_ACCOUNT_ID = #{self.id} AND ((PAYMENT_MODE != 'Chèque') or (credit < 0.001))) AND NOT EXISTS (SELECT * FROM BANK_EXTRACT_LINES WHERE LINE_ID = LINES.ID)")
 end

 def not_pointed_check_deposit
    self.check_deposits.where('pointed = ?', false).all.map {|cd|  [cd.id, "remise chèque du #{cd.deposit_date}",
      0.0, total, "remise ch"]}
 end

end
