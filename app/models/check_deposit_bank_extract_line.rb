# coding: utf-8

# la classe CheckDepositBankExtractLine est une ligne de compte bancaire qui
# correspond à une remise de chèques
# Elle n'a donc pas de lien direct avec une ligne de comptes mais par contre
# elle a un lien avec une remise de chèques.

class CheckDepositBankExtractLine < BankExtractLine
  
  has_one :check_deposit, :dependent=>:nullify, :foreign_key=>"bank_extract_line_id"
  
  validates :bank_extract_id, presence:true  

  def narration
    'Remise de chèques'
  end
 
  def payment
    'Chèque'
  end

  # checck_deposit_bank_extract_line_date
  def cdbel_date
    self.date || self.check_deposit.deposit_date
  end
 

#  def add_check_deposit(cd)
#      self.date = cd.deposit_date
#      self.check_deposit = cd
#  end

  
  def lines
    check_deposit.checks if check_deposit
  end

  # délègue à total_checks de check_deposit
  def credit
    check_deposit.total_checks
  end

  # Zero car une remise de chèques est toujours au crédit du compte
  def debit
    return 0
  end

  # retourne la liste des chèques associés à la remise
  def checks
    check_deposit.checks
  end

  # lock_line verrouille les lignes d'écriture correspondant
  # aux chèques de cette remise.
  #
  # Ceci est appelé par bank_extract (after_save)
  # lorsque l'on verrouille le relevé
  #
  def lock_line
    check_deposit.checks.each {|check_line| check_line.update_attribute(:locked, true) unless check_line.locked? }
  end

  private

  def not_empty
    errors.add(:check_deposit, 'non valable car pas de remise de chèque associée') unless lines
  end



end
