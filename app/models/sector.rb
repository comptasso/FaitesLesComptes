# Sector représente la sectorisation d'activités
# 
# Le secteur a été introduit pour les CE qui doivent tenir un budget de fonctionnement
# et un budget des oeuvres sociales. 
# 
# Cette logique pourra préparer la sectorisation des associations qui ne pourra
# vraiment être utilisée que si le logiciel tient la TVA.
# 
# Néanmoins, cela peut permettre pour une asso d'avoir des livres différents 
# pour un établissement à Lille et un autre à Roubaix et ainsi utiliser des 
# natures et des comptes comptables différents.
# 
# A ce stade, il n'y a pas d'interface puisqu'on ne traite que les CE et que les 
# deux secteurs sont créés lors de la création de l'organisme.
# 
# Un secteur devrait normalement avoir deux livres (recettes et dépenses).
#
#
class Sector < ActiveRecord::Base
  
  include Utilities::JcGraphic
  
  attr_accessible :name, :organism_id
  
  belongs_to :organism
  has_many :books
  has_many :destinations
  has_many :bank_accounts
  has_many :cashes
  
  
  # permet d'ajouter les livres de ce secteur et lui même dans la collection des graphes
  def paves
    books.all << self
  end
  
  # Surcharge de la méthode apportée par Utilities::JcGraphic
  # Le pavé gaphique d'un secteur est de type result_pave
  def pave_char
    ['result_pave', 'result']
  end
  
  # donne les soldes de chaque mois, est appelé par le module JcGraphic pour constuire les graphes
  def monthly_value(date)
    books.all.sum {|b| b.monthly_value(date) }
  end
  
  # renvoie les comptes comptables correspondant aux banques de ce secteur pour l'exercice
  # demandé
  def list_bank_accounts(period)
    bank_accounts.collect {|ba| ba.current_account(period)}
  end
  
  # renvoie les comptes comptables correspondant aux caisses de ce secteur pour l'exercice
  # demandé
  def list_cash_accounts(period)
    cashes.collect {|ca| ca.current_account(period)}
  end
  
    
  def abbreviation
    name[0..3].upcase
  end
  
  
end
