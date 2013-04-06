# coding: utf-8

require 'pdf_document/pdf_balance'

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

  #produit un document pdf en s'appuyant sur la classe PdfBalance issue de PdfDocument::Default
  # et ses classe associées page et table
  def to_pdf
    stamp = provisoire? ? 'provisoire' : ''
    pdf = PdfDocument::PdfBalance.new(period, self,
      title:"Balance générale",
      from_date:from_date, to_date:to_date,
      subtitle:"Du #{I18n::l from_date} au #{I18n.l to_date}",
      select_method:'accounts',
      stamp:stamp)
    pdf.from_number = from_account.number
    pdf.to_number = to_account.number
    pdf.set_columns %w(accounts.id number title period_id)
    pdf.columns_alignements = [:left, :left, :right, :right, :right, :right, :right]
    pdf.set_columns_widths [10, 40, 10, 10, 10, 10, 10]
    pdf.set_columns_titles %w(Numéro Intitulé Débit Crédit Débit Crédit Solde)
    pdf.set_columns_to_totalize [2,3,4,5,6]
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

  

  def balance_lines
    @balance_lines ||= accounts.collect {|acc| balance_line(acc, from_date, to_date)}
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
  def balance_line(account, from = self.period.start_date, to = self.period.close_date)
    { :account_id=>account.id,
      :provisoire=> !account.all_lines_locked?,
      :empty=> account.lines_empty?(from, to),
      :number=>account.number, :title=>account.title,
      :cumul_debit_before=>account.cumulated_debit_before(from),
      :cumul_credit_before=>account.cumulated_credit_before(from),
      :movement_debit=>account.movement(from,to, :debit),
      :movement_credit=>account.movement(from,to, :credit),
      :sold_at=>account.sold_at(to)
    }
  end

  # remplace les points décimaux par des virgules pour s'adapter au paramétrage
    # des tableurs français
    def reformat(number)
      return number unless number.is_a? Numeric
      ('%0.02f' % number).gsub('.', ',')
    end


 

end
