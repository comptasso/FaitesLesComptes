# coding: utf-8
module Admin::NaturesHelper

def account_number(nature, pid)
  nature.accounts.where('period_id=?',pid).first.number
rescue
  '-'
end

def account_title(nature, pid)
  nature.accounts.where('period_id=?',pid).first.title
rescue
  '-'
end

end