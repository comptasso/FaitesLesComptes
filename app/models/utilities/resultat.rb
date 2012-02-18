# coding: utf-8

# ce module est destiné à est inclus dans period pour ajouter des fonctionnalités 
# donnant les résultats mensuels
#
module Utilities::Resultat
  def monthly_results
    self.nb_months.times.map {|m| self.monthly_result(m)}
  end

  def monthly_result(m)
    r=0
    self.books.each do |b|
       r += b.monthly_datas(self)[m]['total_month']
    end
    r
  end


end
