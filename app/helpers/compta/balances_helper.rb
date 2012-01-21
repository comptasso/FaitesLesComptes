# coding: utf-8
module Compta::BalancesHelper
   # bl est un tableau de ligne de la balance
  #  Cette méthode prend les différents éléments d'une page de listing, en l'occurence
  # les lignes de comptes et qui applique le helper debit_credit aux montants
  def balance_prepare_page(bl_page)
  
    tabl= bl_page.collect do |l|
    [ l[:account_number],
      truncate(l[:account_title]),
  debit_credit(l[:cumul_debit_before]),
  debit_credit(l[ :cumul_credit_before]),
  debit_credit(l[:movement_debit]),
  debit_credit(l[ :movement_credit]),
   debit_credit(l[:cumul_debit_at]),
   debit_credit(l[:cumul_credit_at])]
 
   end
tabl.insert(0, ["N° compte", "Libellé", "Débit", "Crédit", "Débit", "Crédit",  "Débit", "Crédit"])

   end

  # on transforme chacun des 6 éléments d'un total de balance avec debit_credit
  def prepare_total_balance(totals)
    totals.map {|t| t= debit_credit(t) }
    
  end
end
