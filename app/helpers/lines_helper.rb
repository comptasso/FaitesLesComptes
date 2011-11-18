module LinesHelper
  def debit_credit(montant)
    if montant > -0.01 && montant < 0.01
      ''
    else
      number_with_precision(montant, precision: 2)
    end
  end
end
