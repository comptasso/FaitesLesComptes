# Classe destinée à remplacer les actuels Compta::Rubriks et Compta::Rubrik
# pour permettre de manipuler les nomenclatures qui servent à établir les documents
# comptables (Actif, Passif, ...)
# 
# ActsAsTree
#
class Rubrik < ActiveRecord::Base
  include ActsAsTree

  belongs_to :folio
  attr_accessible :name, :numeros, :parent_id
  acts_as_tree :order => "name"
  
  
end
