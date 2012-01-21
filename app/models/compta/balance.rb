# coding: utf-8

# une classe correspondant à l'objet balance
class Compta::Balance

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

   protected

  def total(value)
    @balance_lines.sum {|l| l[value]}
  end

 

  def balance_line(account, from=self.period.start_date, to=self.period.close_date)
    {:account_id=>account.id,
      :empty=> account.lines_empty?,
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
