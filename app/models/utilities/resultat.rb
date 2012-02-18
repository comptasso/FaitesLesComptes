# coding: utf-8

# ce module est destiné à est inclus dans period pour ajouter des fonctionnalités 
# donnant les résultats mensuels
#
module Utilities::Resultat
  def monthly_results
    self.list_months('%m-%Y').map {|m| self.monthly_result(m)}
  end

  # m est de la forme 'mm-yyyy'
  def monthly_result(m)
    self.books.all.sum {|b| b.monthly_sold(m)}
  end


end
