module LinesHelper
  def debit_credit(montant)
    if montant > -0.01 && montant < 0.01
      ''
    else
      number_with_precision(montant, precision: 2)
    end
  rescue
    ''
  end

  def two_decimals(montant)
    sprintf('%0.02f',montant)
  rescue
    '0.00'
  end
end
