# coding: utf-8
module Admin::AccountsHelper
def t_used(account)
  account.used? ? 'Oui' : 'Non'
end

end