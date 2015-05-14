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
# Un secteur a deux champs : name et organism_id
# 
# Le secteur peut être Global (cas général), Fonctionnement ou ASC (cas des CE)
# qui ont ces deux secteurs. 
# 
# 
# Un secteur devrait normalement avoir deux livres (recettes et dépenses).
#
#
class Sector < ActiveRecord::Base
  
  include Utilities::JcGraphic
  
  # attr_accessible :name, :organism_id
  
  belongs_to :organism
  has_many :books
  has_many :destinations
  has_many :bank_accounts
  has_many :cashes
  has_one :income_book
  has_one :outcome_book
  has_many :accounts # rajouté lors de la sectorisation des comptes
  
  validates :organism_id, presence:true
  validates :name, inclusion:{in:%w(Global Fonctionnement ASC Commun)}
  
  # permet d'ajouter les livres de ce secteur et lui même dans la collection des graphes
  def paves
    books.to_a << self
  end
  
    
 
  
  # renvoie les commptes comptables correspondant aux banque de ce secteur 
  # pour l'exercice demandé et ajoute d'éventuels comptes bancaires relevant 
  # du secteur Commun s'il en existe
  def list_bank_accounts_with_communs(period)
    list_bank_accounts(period) + list_common_bank_accounts(period)
  end
  
  
  # renvoie les comptes comptables correspondant aux caisses de ce secteur pour l'exercice
  # demandé
  def list_cash_accounts(period)
    cashes.collect {|ca| ca.current_account(period)}
  end
  
    
  def abbreviation
    name[0..3].upcase
  end
  
 # mise en place des fonctions qui permettent de construire les graphiques avec 
 # très peu d'appel à la base de données
 # récupère les soldes pour une caisse pour un exercice
 #
 # Renvoie un hash selon le format suivant 
 # {"09-2013"=>"-24.00", "01-2013"=>"-75.00", "08-2013"=>"-50.00"}
 #
 # Les mois où il n'y a pas de valeur ne renvoient rien.
 # Il faut donc ensuite faire un mapping ce qui est fait par la méthode
 # build_datas de Utilities::Graphic
 # 
 # TODO : Optimiser cette requête en faisant une liste des mois voulus
 # avec un join left, ce qui évitera les mois qui ne sont pas remplis
 #
 def query_monthly_datas(period)
   bids = books.collect(&:id).join(', ')
   
   sql = <<-hdoc
     SELECT 
         to_char(writings.date, 'MM-YYYY') AS mony,
         SUM(compta_lines.credit) - SUM(compta_lines.debit) AS valeur 
     FROM 
         writings, 
         compta_lines
     WHERE
       writings.book_id IN (#{bids}) AND 
       writings.date >= '#{period.start_date}' AND 
       writings.date <= '#{period.close_date}' AND 
       compta_lines.writing_id = writings.id AND 
       nature_id IS NOT NULL
     GROUP BY mony
hdoc

   res = VirtualBook.find_by_sql(sql)
   h = Hash.new('0')
   res.each {|r| h[r['mony']]= r["valeur"] }
   h
   
   end
   
 protected
 
  # renvoie les comptes comptables correspondant aux banques de ce secteur pour l'exercice
  # demandé
  def list_bank_accounts(period)
    bank_accounts.collect {|ba| ba.current_account(period)} 
  end
  
  # renvoie la liste des comptes bancaire communs
  def list_common_bank_accounts(period)
    organism.bank_accounts.communs.collect {|ba| ba.current_account(period)}
  end
  
  
  
  
end
