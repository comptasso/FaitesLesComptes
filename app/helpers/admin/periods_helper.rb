# coding: utf-8

module Admin::PeriodsHelper

  def period_class(p)
    (p == @period) ? 'current' : 'other'
  end


end