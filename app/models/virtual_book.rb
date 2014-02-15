# coding: utf-8

require 'book.rb'

# un VirtualBook est un modèle non persistent qui représente un livre de caisse ou de banque
# Le virtual_book fonctionne en trésorerie (entrées sorties) et le sold est donc
# inversé par rapport au solde comptable.
#
# Un virtual_book hérite de Book et donc des méthodes Utilities::JcGraphic et
# Utilities::Sold
#
# L'attribut virtual représente la classe sous jacente, donc une caisse ou un compte bancaire
# Cet attribut doit être rempli par la partie appelante
# 
# 
# pave_char (également surchargé) permet d'indiquer le type de graphique que l'on souhaite pour l'affichage du DashBoard
#
# Les virtual_books se créent par la méthode Organism#virtual_books définie par un has_many dans la classe Organism
#
# En pratique, Organism propose les méthodes cash_books et bank_books pour retourner une collection de virtual books.
#
class VirtualBook < Book

  attr_accessor :virtual

  belongs_to :organism
  
  delegate :nickname, :export_pdf, :create_export_pdf, :to=>:virtual
  
  def lines
    virtual.compta_lines
  end
  
  # dans le cas d'un virtual book créé à partir d'un compte bancaire, le titre
  # est nil donc on essaye alors nickname
  def title
    t = read_attribute(:title)
    t || nickname if virtual.respond_to? :nickname
  end
  
  # extrait les lignes entre deux dates. Cette méthode ne sélectionne pas sur un exercice.
  # TODO voir s'il ne faudrait pas deléguer cette méthode à la classe virtual (déjà définie dans BankAccount par un scope)
  def extract_lines(from_date, to_date)
    virtual.compta_lines.joins(:writing).where('writings.date >= ? AND writings.date <= ?', from_date, to_date).order('writings.date')
  end

  # renvoie les charactéristique du pavé, en l'occurence la racine du partial et 
  # la classe à utiliser pour le pavé.
  #
  # Cela peut donc être ['cash_pave', 'cash_book'] ou  ['bank_account_pave', 'bank_account_book']
  #
  # TODO : en fait cela relève de la responsabilité d'une classe pavé
  #
  def pave_char
    vcu = virtual.class.name.underscore
    [vcu + '_pave', vcu + '_book']
  end
  
 
  
  # surcharge de cumulated_at pour avoir toutes les méthodes de sold
  # celà consiste juste à une inversion de la méthode par défaut de l'objet 
  # sous jacent (une caisse ou un compte bancaire) pour avoir des soldes 
  # intuitifs.
  def cumulated_at(date = Date.today, dc)
    -virtual.cumulated_at(date, dc)
  end
  
  def sold_at(date = Date.today)
    -virtual.sold_at(date)
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
  # map_query_months(period)
  #
  def query_monthly_datas(period)
   
 
    acc = virtual.current_account(period)  
    return Hash.new('0') unless acc # ce cas (pas de compte) peut arriver si le 
    # compte bancaire a été créé sur un exercice alors que le précédent exercice était fermé.
    sql = <<-hdoc
 SELECT 
     to_char(writings.date, 'MM-YYYY') AS mony,
     SUM(compta_lines.debit) - SUM(compta_lines.credit) AS valeur 
 FROM 
     writings, 
     compta_lines
 WHERE 
     writings.id = compta_lines.writing_id AND
     compta_lines.account_id = #{acc.id} 
 GROUP BY mony
    hdoc

    res = VirtualBook.connection.execute( sql.gsub("\n", ''))
    h = Hash.new('0')
    res.each {|r| h[r['mony']]= r["valeur"] }
    
    h
   
  end
 
  protected 
  
 # construit un graphique des données mensuelles du livre par défaut avec deux exercices
  def default_graphic(period)
    @graphic = Utilities::Graphic.new(self, period, :line)
  end
 
 
 
 

end
