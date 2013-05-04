# coding: utf-8
require 'options_for_association_select'

module Admin::AccountsHelper
def t_used(account)
  account.used? ? 'Oui' : 'Non'
end



end