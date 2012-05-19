# coding: utf-8

# la classe CheckDepositBankExtractLine est une ligne de compte bancaire qui
# correspond à une remise de chèques
# Elle n'a donc pas de lien direct avec une ligne de comptes mais par contre
# elle a un lien avec une remise de chèques.

class CheckDepositBankExtractLine < BankExtractLine
  belongs_to :check_deposit
  
  after_initialize :prepare_datas

  validates :check_deposit_id, presence:true
  validates :bank_extract_id, presence:true

  

  def prepare_datas
      cd = self.check_deposit
      self.date = cd.deposit_date
      @debit=0
      @credit=cd.total_checks
      @narration = 'Remise de chèques'
      @payment = 'Chèques'
      @blid="check_deposit_#{cd.id}"
  end

  
  

  
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

  private

  def not_empty
    errors.add(:check_deposit, 'non valable car pas de remise de chèque associée') unless lines
  end


#  def link_to_source
#     self.check_deposit.update_attribute(:bank_extract_id, self.bank_extract_id)
#  end


end
