# coding: utf-8

# require 'pdf_document/pdf_balance'

# une classe correspondant à l'objet balance. Cette classe a une table virtuelle
# mais le controller ne sauve pas l'objet.
#
# La table virtuelle permet de bénéficier des scope et callbacks de
# ActiveRecord.
#
# Balance se crée soit en fournissant tous les paramètres, soit
# en fournissant period_id et en appelant with_default_values
# 
#
#
class Compta::Balance < ActiveRecord::Base

  include Utilities::ToCsv
  include Utilities::PickDateExtension # apporte la méthode de classe pick_date_for
  
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :from_date, :string
  column :to_date, :string
  column :from_account_id, :integer
  column :to_account_id, :integer
  column :period_id, :integer

  attr_accessible :from_date, :to_date, :from_account_id, :to_account_id, 
    :period_id, :from_date_picker, :to_date_picker

  attr_accessor :nb_per_page

  

  pick_date_for :from_date, :to_date # donne les méthodes from_date_picker et to_date_picker
  # utilisées par le input as:date_picker 

  belongs_to :period
  # des has_one seraient plus intuitifs mais cela nécessiterait que le champ _id
  # soit dans la table accounts. 
  belongs_to :from_account, :class_name=>"Account"
  belongs_to :to_account, :class_name=>"Account" 
  # has_many :accounts, :through=>:period, :conditions=> lambda { } 

 # je mets within_period en premier car je préfère les affichages Dates invalide ou hors limite
 # que obligatoire (sachant que le form n'affiche que la première erreur).
  validates :from_date, :to_date, :within_period=>true
  validates :from_date, :to_date, :from_account_id, :to_account_id, :period_id, :presence=>true


  # retourne la liste ordonnées des comptes demandés.
  #
  # Swap les comptes si le to_account est avant le form_account
  def accounts
    self.from_account, self.to_account = to_account, from_account if to_account.number  < from_account.number
    period.accounts.order('number').where('number >= ? AND number <= ?', from_account.number, to_account.number)
  end

  # indique si le listing doit être considéré comme un brouillard
  # ou une édition définitive.
  # Cela se fait en s'appuyant sur account#all_lines_locked?
  def provisoire?
     accounts.joins(:compta_lines).where('locked = ?', false).any?
  end

  #produit un document pdf en s'appuyant sur la classe PdfBalance issue de PdfDocument::Totalized
  # et ses classe associées page et table
  def to_pdf
    stamp = provisoire? ? 'provisoire' : ''
    pdf = Editions::Balance.new(period, self,
      title:"Balance générale",
      stamp:stamp)
    pdf
  end

   # valeurs par défaut, retourne self permettant de chainer les méthodes
  def with_default_values
    if period
      self.from_date ||= period.start_date
      self.to_date ||= period.close_date
      self.from_account ||= period.accounts.order('number ASC').first
      self.to_account ||= period.accounts.order('number ASC').last
    end
    self
  end
  
  
  # requete SQL pour accélérer la construction d'une balance. Le benchmark donne
  # 2,5 secondes par une méthode classique et cela est ramené à 2 centièmes.
  # 
  # Les paramètres doivent avoir été définis
  def query_balance_lines
     sql = <<EOF
     SELECT accounts.id AS account_id, accounts.number, accounts.title, 
            debut.deb_debit AS cumul_debit_before, 
            debut.deb_credit AS cumul_credit_before,
            fin.fin_debit AS movement_debit,
            fin.fin_credit AS movement_credit, fin.no_empty
 FROM 
accounts, 
 
(SELECT accounts.id AS acco_id, accounts.number AS num, COALESCE(deb_debit, 0.00) AS deb_debit, COALESCE(deb_credit, 0.00) AS deb_credit 
 FROM accounts LEFT JOIN 
 (SELECT compta_lines.account_id AS clacoid, COALESCE(SUM(debit), 0) AS deb_debit, COALESCE(SUM(credit), 0) AS deb_credit
  FROM compta_lines JOIN writings ON (compta_lines.writing_id = writings.id)
  WHERE writings.date < '#{from_date}' GROUP BY account_id) AS cls ON cls.clacoid = accounts.id) debut,

(SELECT accounts.id AS acco_id, accounts.number, COALESCE(tot_debit, 0.00) AS fin_debit, COALESCE(tot_credit, 0.00) AS fin_credit, no_empty 
 FROM accounts LEFT JOIN 
 (SELECT compta_lines.account_id AS clacoid, SUM(debit) AS tot_debit, SUM(credit) AS tot_credit, COUNT(*) AS no_empty
  FROM compta_lines JOIN writings ON (compta_lines.writing_id = writings.id)
  WHERE (writings.date >= '#{from_date}' AND writings.date <= '#{to_date}') GROUP BY account_id) AS clto ON clto.clacoid = accounts.id) fin

 WHERE accounts.id = debut.acco_id AND debut.acco_id = fin.acco_id AND accounts.period_id = #{period.id} AND
 (accounts.number BETWEEN '#{from_account.number}' AND '#{to_account.number}')
 ORDER BY accounts.number 
EOF
    Compta::Balance.connection.execute( sql.gsub("\n", ''))
  end

  

  def balance_lines
    @balance_lines ||= query_balance_lines.collect {|acc| balance_line(acc)}
  end

  # calcule les totaux généraux de la balance
  def total_balance
    [total(:cumul_debit_before),
     total(:cumul_credit_before),
     total(:movement_debit),
     total(:movement_credit),
     total(:sold_at)]
  end

   

  def to_csv(options = {col_sep:"\t"})
      CSV.generate(options) do |csv|
        csv << ['', '', 'Soldes au', I18n.l(from_date),'Mouvements', 'de la période', "Soldes au #{I18n.l(to_date)}"]
        csv << %w(Numéro Intitulé Débit Crédit Débit Crédit Solde)
        balance_lines.each do |bl|
        csv << [bl[:number], bl[:title], bl[:cumul_debit_before], bl[:cumul_credit_before],
            bl[:movement_debit], bl[:movement_credit], bl[:sold_at]].collect {|val| reformat(val)}
        end
        csv << ['Totaux', ''] + total_balance.collect {|val| reformat(val)}
      end
    end

  
  protected

  # calcule les totaux pour l'index demandé (:cumul_debit_before,...)
  def total(index)
    balance_lines.sum {|l| l[index]}
  end

  # construit la ligne qui sera affichée pour chaque compte demandé, sous forme d'un hash
  def balance_line(row) 
    { :account_id=>row["account_id"].to_i,
      :empty=> !row["no_empty"],  # permet d'afficher l'icone listing dans la vue
      :number=>row["number"],
      :title=>row["title"],
      :cumul_debit_before=>row["cumul_debit_before"].to_f,
      :cumul_credit_before=>row["cumul_credit_before"].to_f,
      :movement_debit=>row["movement_debit"].to_f,
      :movement_credit=>row["movement_credit"].to_f,
      :sold_at=>row["movement_credit"].to_f - row["movement_debit"].to_f + 
        row["cumul_credit_before"].to_f - row["cumul_debit_before"].to_f
    }
  end

  # remplace les points décimaux par des virgules pour s'adapter au paramétrage
    # des tableurs français
    def reformat(number)
      return number unless number.is_a? Numeric
      ('%0.02f' % number).gsub('.', ',')
    end


 

end
