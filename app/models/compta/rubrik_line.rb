#coding utf-8


module Compta

  #
  # La classe RubrikLine est une classe énumerable qui est construite par une
  # Rubrik à l'aide de RubrikParser pour déterminer les comptes
  # Elle donne un numéro de compte(qui est le premier compte qui l'a constitué,
  # un intitulé (idem), une valeur brute, un amortissement et un net
  #
  #  sens permet d'indiquer débit ou credit, ou actif et passif de façon
  #  à gérer les signes.
  #
  class RubrikLine

    attr_reader :brut, :amortissement, :select_num

    def initialize(period, sens,  select_num, brut = true )
      @period = period
      @sens = sens
      @select_num = select_num
      @brut = brut
      @account = period.accounts.find_by_number(@select_num)
      set_value(@brut)
   end

    

    def title
      @account.title rescue @period.previous_period.accounts.find_by_number(@select_num).title
    end

    def set_value(brut = true)
      s = @account.sold_at(@period.close_date)
      # prise en compte de la colonne brut ou amortissement
       r =  @brut ? [s, 0] : [0, -s]

      # prise en compte du sens
      if @sens == :actif || @sens == :debit
        r.collect! {|v| -v }
      end
      @brut, @amortissement =  r
    end

    # retourne la valeur nette par calcul de la différence entre brut et amortissement
    def net
      @brut - @amortissement
    end

    def previous_net
      puts @period.inspect
      if pp = @period.previous_period?
        RubrikLine.new(pp, @sens, @select_num, @brut).net
      else
        0
      end
    end

    # affiche la RibrikLine
    def to_s
      "#{@select_num} - #{title} - #{@brut} - #{@amortissement} - #{net} - #{previous_net}"
    end


  end
end