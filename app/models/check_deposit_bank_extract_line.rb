# coding: utf-8

# la classe CheckDepositBankExtractLine est une ligne de compte bancaire qui
# correspond à une remise de chèques
# Elle n'a donc pas de lien direct avec une ligne de comptes mais par contre
# elle a un lien avec une remise de chèques.

class CheckDepositBankExtractLine < BankExtractLine
  belongs_to :check_deposit
 #  has_many :check_lines, through:check_deposit
  after_initialize :prepare_datas

  def prepare_datas
      cd=self.check_deposit
      @date=cd.deposit_date
      @debit=0
      @credit=cd.total_checks
      @narration = 'remise de cheques'
      @payment = 'Chèques'
      @blid="check_deposit_#{cd.id}"
  end

  def link_to_source
     self.check_deposit.update_attribute(:bank_extract_id, self.bank_extract_id)
  end


end
