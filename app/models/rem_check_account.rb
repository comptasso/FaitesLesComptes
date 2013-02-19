# coding: utf-8

# Classe dont la seule utilité est de permettre de traiter l'affichage du support de
# la même manière pour les bank_account, les cash et les remises de chèques
#
# La méthode support fait appel à accountable.
# Dans le modèle account, accountable a été surchargée pour renvoyer un RemCheckAccount si
# tel est le type et ainsi appeler la méthode to_s.
#
class RemCheckAccount < ActiveRecord::Base

  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  attr_accessible nil

  has_many :accounts, :as=> :accountable

  def to_s
    'A encaisser'
  end

 end