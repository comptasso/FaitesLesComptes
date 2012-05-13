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
  validate :not_empty
end
