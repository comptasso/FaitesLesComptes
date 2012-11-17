# coding: utf-8

module Compta::SheetsHelper

  def totals_result_with_account(rubrik)
    retour  = rubrik.totals
    retour[0] = '12 - ' + retour[0].to_s
    retour
  end



end