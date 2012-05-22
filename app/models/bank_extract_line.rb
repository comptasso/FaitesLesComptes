# coding: utf-8


# La classe sert de mère pour les différents types de BankExtractLine avec une
# seule table (STI)
#
# Les deux sous classes (actuellement) sont StandardBankExtractLine et
# CheckDepositBankExtractLine
#
# Cette classe recevra les méthodes communes telles que up et down pour la
# gestion des positions
#
class BankExtractLine < ActiveRecord::Base

  belongs_to :bank_extract

  has_and_belongs_to_many :lines, :before_add=>:not_already_included



  acts_as_list :scope => :bank_extract

  # validate :not_empty est délégué aux sous classes
  # par le biais de sheck_deposit_id :presence=>true
  # et par le biais d'une mathode not_empty pour StandardBankExtractLine

  attr_reader :payment, :narration, :debit,  :credit

  before_destroy :remove_from_list

 
  # chainable indique si le bank_extract_line peut être relié à son suivant
  # Ce n'est possible que si
  #  - ce n'est pas une remise de chèque
  #  - ce n'est pas le dernier
  #  - ils ne sont pas du même sens.
  #  - le suivant n'est pas une remise de chèque
  #
  def chainable?
    return false if is_a?(CheckDepositBankExtractLine)
    return false if last?
    return false if (lower_item.debit == 0 && self.debit != 0) || (self.credit != 0 && lower_item.credit == 0)
    return false if  lower_item.is_a?(CheckDepositBankExtractLine)
    true
  end

  def not_already_included(line)
    if line.bank_extract_lines.count > 0
      logger.warn "tried to include line #{line.id} which was already included in a bank_extract_line"
      raise ArgumentError
    end
  end



  
end
