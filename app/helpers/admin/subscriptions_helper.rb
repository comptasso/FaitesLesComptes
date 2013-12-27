# coding: utf-8
module Admin::SubscriptionsHelper
  def date_de_fin(sub)
    if sub.permanent
      'Permanent'
    else
      I18n.l(sub.end_date)
    end
  end
end
