# coding: utf-8

# une classe correspondant à l'objet balance. Cette classe a une table
# mais le controller ne sauve pas l'objet.
# La table est préférable pour pouvoir bénéficier des scope et callbacks de
# ActiveRecord.
#
#
class Compta::Balance < ActiveRecord::Base
  

  include Utilities::PickDateExtension # apporte la méthode de classe pick_date_for

  pick_date_for :from_date, :to_date # donne les méthodes begin_date_picker et end_date_picker
  # utilisées par le input as:date_picker

  

  belongs_to :period
  # des has_one seraient plus intuitifs mais cela nécessiterait que le champ _id
  # soit dans la table accounts. 
  belongs_to :from_account, :class_name=>"Account"
  belongs_to :to_account, :class_name=>"Account" 
  has_many :accounts, :through=>:period

 # je mets date_within_period en premier car je préfère les affichages Dates invalide ou hors limite
 # que obligatoire (sachant que le form n'affiche que la première erreur).
  validates :from_date, :to_date, date_within_period:true
  validates :from_date, :to_date, :from_account_id, :to_account_id, :period_id, :presence=>true
  

   # valeurs par défaut
  def with_default_values
    if period
      self.from_date ||= period.start_date
      self.to_date ||= period.close_date
      self.from_account ||= period.accounts.order('number ASC').first
      self.to_account ||= period.accounts.order('number ASC').last
    end
    self
  end

  def range_accounts
    self.from_account, self.to_account = to_account, from_account if to_account.number  < from_account.number
    accounts.where('number >= ? AND number <= ?', from_account.number, to_account.number)
  end

    def balance_lines
    @balance_lines ||= range_accounts.collect {|acc| balance_line(acc, from_date, to_date)}
  end

  def total_balance
    [self.total(:cumul_debit_before), self.total(:cumul_credit_before),self.total(:movement_debit),
      self.total(:movement_credit),self.total(:cumul_debit_at),self.total(:cumul_credit_at)
    ]
  end

  # renvoie les lignes correspondant à la page demandée
  def page(n)
    return nil if n > self.total_pages
    balance_lines[(NB_PER_PAGE*(n-1))..(NB_PER_PAGE*n-1)]

  end

  def sum_page(n)
    [self.total_page(:cumul_debit_before, n), self.total_page(:cumul_credit_before, n),self.total_page(:movement_debit,n ),
      self.total_page(:movement_credit,n ),self.total_page(:cumul_debit_at,n),self.total_page(:cumul_credit_at,n)
    ]

  end

  # indique si le listing doit être considéré comme un brouillard
  # ou une édition définitive.
  # Cela se fait en regardant si toutes les lignes sont locked?
  def provisoire?
    balance_lines.any? {|bl| bl[:provisoire]==true } ? true : false
  end
  # calcule le nombre de page du listing en divisant le nombre de lignes
  # par un float qui est le nombre de lignes par pages,
  # puis arrondi au nombre supérieur
  def total_pages
    (balance_lines.size/NB_PER_PAGE.to_f).ceil
  end


  def bl_to_array
    self.balance_lines.collect do |l|
      [ l[:account_number],
        l[:account_title],
        l[:cumul_debit_before],
        l[ :cumul_credit_before],
        l[:movement_debit],
        l[ :movement_credit],
        l[:cumul_debit_at],
        l[:cumul_credit_at]]
    end
  end


  protected

  def total(value)
    balance_lines.sum {|l| l[value]}
  end

  def total_page(value, n=1)
    self.page(n).sum {|l| l[value]}
  end



  def balance_line(account, from=self.period.start_date, to=self.period.close_date)
    {:account_id=>account.id,
      :account_title=>account.title,
      :account_number=>account.number,
      :empty=> account.lines_empty?(from, to),
      :provisoire=> !account.all_lines_locked?,
      :number=>account.number, :title=>account.title,
      :cumul_debit_before=>account.cumulated_before(from, :debit),
      :cumul_credit_before=>account.cumulated_before(from, :credit),
      :movement_debit=>account.movement(from,to, :debit),
      :movement_credit=>account.movement(from,to, :credit),
      :cumul_debit_at=>account.cumulated_at(to,:debit),
      :cumul_credit_at=>account.cumulated_at(to,:credit)
    }

  end

 

end
