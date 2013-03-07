# coding: utf-8

module Admin::PeriodsHelper

  # permet de définir la classe (au sens CSS) pour une ligne de 
  # la table de admin#periods#index.html
  def period_class(p)
    (p == @period) ? 'current' : 'other'
  end


end