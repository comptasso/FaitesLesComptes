# coding: utf-8

module Compta::SheetsHelper

  # Prend la rubrique résultat et lui ajoute le compte 12
  # dans le libellé
  def totals_result_with_account(rubrik) 
    retour  = rubrik.totals
    retour[0] = '12 - ' + retour[0].to_s
    retour
  end



end