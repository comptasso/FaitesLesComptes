# coding: utf-8

# une classe correspondant à l'objet balance
class Compta::Balance

  attr_reader :period
  
  def initialize(period)
    @period=period
  end
  
  def accounts
    @period.accounts    
  end



end
