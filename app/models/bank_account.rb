# -*- encoding : utf-8 -*-

class BankAccount < ActiveRecord::Base
  belongs_to :organism
  has_many :check_deposits
  has_many :bank_extracts
  
  # un compte bancaire a un compte comptable par exercice
  has_many :accounts, :as=> :accountable
  has_many :lines, :through=>:accounts
  
  validates :number, :uniqueness=>{:scope=>[:organism_id, :name]}
  validates :name, :number,  presence: true

  after_create :create_accounts

  # retourne le dernier extrait de compte bancaire
 # sur la base de la date de fin
 def last_bank_extract
   bank_extracts.order(:end_date).last
 end

 def current_account(period)
   accounts.where('period_id = ?', period.id).first
 end

  # Méthode qui donne le montant du dernier solde bancaire
  # par ordre de date
  def last_bank_extract_sold
    last_bank_extract.end_sold
  rescue
    0
  end

  # renvoie un array avec débit et crédit du relevé bancaire
  def last_bank_extract_debit_credit
    return last_bank_extract.debit, last_bank_extract.credit
  end

  # renvoie la date de fin du dernier relevé bancaire
  def last_bank_extract_day
    self.bank_extracts.order(:end_date).last.end_date
  rescue
    Date.today.beginning_of_month - 1
  end

 
 # créé un nouvel extrait bancaire rempli à partir des informations du précédent
 # le mois courant et zéro si c'est le premier
  def new_bank_extract
    previous_be = last_bank_extract
    if previous_be
      bank_extracts.new(begin_date: previous_be.end_date + 1.day,
                        end_date: (previous_be.end_date + 1.day).end_of_month,
                        begin_sold: previous_be.end_sold)
    else
      bank_extracts.new(begin_date: Date.today.beginning_of_month,
                        end_date: Date.today.end_of_month,
                        begin_sold: 0)
    end
  end

 # trouve toutes les lignes non pointées -np pour not pointed
 # les lignes à sélectionner sont celles qui correspondent aux comptes comptables
 # appartenant à ce compte bancaire
 # 
# Appelé par la classe NotPointedLines 
 #
  def np_lines
   
    Line.find_by_sql("SELECT lines.* FROM lines INNER JOIN accounts ON
 lines.account_id = accounts.id WHERE accounts.accountable_id = #{id} AND accounts.accountable_type = 'BankAccount'
  AND NOT EXISTS (SELECT * FROM BANK_EXTRACT_LINES_LINES WHERE LINE_ID = LINES.ID) ORDER BY line_date ASC")

 end

 # fait le total débit des lignes non pointées et des remises chèqures déposées
 # donc en fait c'est le total débit des lignes.
 # cette méthode est là par souci de symétrie avec total_credit_np
 def total_debit_np
   self.total_debit_np_lines
 end

 # fait le total crédit des lignes non pointées et des remises chèqures déposées
 def total_credit_np
   self.total_credit_np_lines +  self.total_credit_np_check_deposits
 end

 # solde des lignes non pointées
 def sold_np
   self.total_credit_np - self.total_debit_np
 end

 def sold
   last_bank_extract_sold + sold_np
 end

 def first_bank_extract_to_point
   self.bank_extracts.where('locked = ?', false).order('begin_date ASC').first
 end

 # Trouve toutes les remises de chèques qui ne sont pas encore pointées
 def np_check_deposits
   self.check_deposits.not_pointed
 end

 def total_credit_np_check_deposits
   self.np_check_deposits.all.sum(&:total_checks)
 end


 # crée des bank_extract_lines à partir des lignes non pointées
 # méthode utilisée pour le pointage des comptes par bank_extract_controller
 def not_pointed_check_deposits
    self.np_check_deposits.map {|cd| c = CheckDepositBankExtractLine.new(check_deposit_id:cd.id); c}
 end


 def nb_lines_to_point
   np_lines.size + np_check_deposits.count
 end

 

 def unpointed_bank_extract?
   self.bank_extracts.where('locked = ?', false).count > 0 ? true :false
 end


 def acronym
   name.gsub(/[a-z\séèùôîûâ]/, '')
 end

 # utilisée dans les select pour avoir un champ plus sympathique que le seul numéro
 def to_s
   "#{acronym} #{number}"
 end

  def to_option
    "#{self.class.name}_#{id}"
  end




 protected

#  totalise débit et crédit de toutes les lignes non pointées
 def total_debit_np_lines
   np_lines.sum(&:debit)
 end

  #  totalise débit et crédit de toutes les lignes non pointées
 def total_credit_np_lines
   np_lines.sum(&:credit)
 end


 # appelé par le callback after_create, crée un compte comptable de rattachement
 # pour chaque exercice ouvert.
 def create_accounts
   logger.info 'création des comptes liés au compte bancaire'
   # demande un compte de libre sur l'ensemble des exercices commençant par 51
   n = Account.available('512') # un compte 512 avec un précision de deux chiffres par défaut
   organism.periods.where('open = ?', true).each do |p|
     self.accounts.create!(number:n, period_id:p.id, title:self.name)
   end
 end


end

# PARTIE CREATION DE GRAPHIQUE

class BankAccount < ActiveRecord::Base
 include Utilities::JcGraphic

 
 # monthly_value est la méthode par défaut utilisée par JcGraphic pour avoir la valeur d'un mois
#  def monthly_value(date)
#
#    be=bank_extracts.find_nearest(date)
#    be ?  be.end_sold : 'null' # s'il y a  un extrait correspondant, donne son solde, sinon null
#    # jqplot traduira ce null en rien par la fonction parseFloat qui est appelée lors de la
#    # construction des graphes
#  end

end