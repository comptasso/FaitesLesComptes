# coding: utf-8



# une classe correspondant à l'objet balance
class Compta::Balance
  NB_PER_PAGE=24

  attr_reader :period, :balance_lines
  
  def initialize(period, accounts=nil, from=nil, to = nil)
    @period=period
      accounts ||= self.period.accounts.all
      from ||= @period.start_date
      to ||= @period.close_date
    @balance_lines= accounts.collect {|a| self.balance_line(a,from,to)}
  end
  
  def accounts
    @period.accounts    
  end

 
  def total_balance
    [self.total(:cumul_debit_before), self.total(:cumul_credit_before),self.total(:movement_debit),
      self.total(:movement_credit),self.total(:cumul_debit_at),self.total(:cumul_credit_at)
    ]
  end

   # renvoie les lignes correspondant à la page demandée
  def page(n)
    return nil if n > self.total_pages
    @balance_lines[(NB_PER_PAGE*(n-1))..(NB_PER_PAGE*n-1)]
    
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
      @balance_lines.any? {|bl| bl[:provisoire]==true } ? true : false
   end
  # calcule le nombre de page du listing en divisant le nombre de lignes
  # par un float qui est le nombre de lignes par pages,
  # puis arrondi au nombre supérieur
  def total_pages
    (@balance_lines.size/NB_PER_PAGE.to_f).ceil
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
    @balance_lines.sum {|l| l[value]}
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
