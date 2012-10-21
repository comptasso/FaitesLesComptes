# coding: utf-8
module Compta::BalancesHelper
  def begin_column_title(date)
    if date == @period.start_date
      "Soldes d'ouverture"
    else
      "Soldes au #{l date}"
    end
  end
end
