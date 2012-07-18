# coding: utf-8
require 'options_for_association_select'

module Admin::AccountsHelper
def t_used(account)
  account.used? ? 'Oui' : 'Non'
end

# Helper permettant de construire les options pour le form
# La classe OptionsForAssociationSelect est définie dans lib
def options_for_accounts(period)
  [OptionsForAssociationSelect.new('Recettes', :recettes_natures, period), OptionsForAssociationSelect.new('Dépenses',:depenses_natures, period)]
end

end