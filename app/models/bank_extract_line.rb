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

  has_and_belongs_to_many :lines, uniq:true

  acts_as_list :scope => :bank_extract
#  validate :not_empty

  attr_reader :payment, :narration, :debit,  :credit

  # chainable indique si le bank_extract_line peut être relié à son suivant
  # Ce n'est possible que si
  #  - ce n'est pas une remise de chèque
  #  - ce n'est pas le dernier.
  #  - le suivant n'est pas une remise de chèque
  #
  #
  def chainable?
    return false if is_a?(CheckDepositBankExtractLine)
    return false if last?
    return true if  !lower_item.is_a?(CheckDepositBankExtractLine) 
  end
  
end
