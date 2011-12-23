# -*- encoding : utf-8 -*-

class BankAccount < ActiveRecord::Base
  belongs_to :organism
  has_many :check_deposits
  has_many :bank_extracts

  # Méthode qui donne le montant du dernier solde bancaire
  # par ordre de date
  
  def last_bank_extract_sold
    self.last_bank_extract.end_sold
  rescue
    0
  end

  def last_bank_extract_debit_credit
   return self.last_bank_extract.debit, self.last_bank_extract.credit
  end

  def last_bank_extract_day
    self.bank_extracts.order(:end_date).last.end_date
  rescue
    Date.today.beginning_of_month - 1
  end
 # trouve toutes les lignes non pointées -np pour not pointed
 def np_lines
   Line.find_by_sql("SELECT id, narration, debit, credit, payment_mode, line_date
    FROM LINES WHERE (BANK_ACCOUNT_ID = #{self.id} AND ((PAYMENT_MODE != 'Chèque') or (credit < 0.001))) AND NOT EXISTS (SELECT * FROM BANK_EXTRACT_LINES WHERE LINE_ID = LINES.ID)")
 end

 #  totalise débit et crédit de toutes les lignes non pointées
 def total_debit_np_lines
   np_lines.sum(&:debit)
 end

  #  totalise débit et crédit de toutes les lignes non pointées
 def total_credit_np_lines
   np_lines.sum(&:credit)
 end


 # fait le total débit des lignes non pointées et des remises chèqures déposées
 # donc en fait c'est le total débit des lignes.
 # cette méthode est là par souci de symétrie avec total_credit_np
 def total_debit_np
   self.total_debit_np_lines
 end

 # fait le total crédit des lignes non pointées et des remises chèqures déposées
 def total_credit_np
   self.total_credit_np_lines +  self.total_credit_np_check_deposits
 end

 def sold_np
   self.total_credit_np - self.total_debit_np
 end

 # crée des bank_extract_lines à partir des lignes non pointées
 def not_pointed_lines
  self.np_lines.map {|l| BankExtractLine.new(:line_id=>l.id)}
 end

# Trouve toutes les remises de chèques qui ne sont pas encore pointées
 def np_check_deposits
   self.check_deposits.where('bank_extract_id IS NULL')
 end

 def total_credit_np_check_deposits
   self.np_check_deposits.all.sum(&:total)
 end

 # Crée des bank_extract_lines à partir des check_deposits non pointés
 def not_pointed_check_deposits
    self.np_check_deposits.map {|cd| BankExtractLine.new(:check_deposit_id=>cd.id)}
 end

 def lines_to_point
   self.not_pointed_lines +  self.not_pointed_check_deposits
 end



 def last_bank_extract
    self.bank_extracts.order(:end_date).last
  end

end
