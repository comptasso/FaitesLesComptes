# coding: utf-8


module Admin::SubscriptionsHelper
  def date_de_fin(sub)
    if sub.end_date
      I18n.l(sub.end_date)
    else
      'Permanent'
    end
  end
  
end
