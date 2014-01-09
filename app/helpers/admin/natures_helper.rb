# coding: utf-8
require 'options_for_association_select'

module Admin::NaturesHelper


# Helper permettant de construire les options pour le champ account du formulaire
# La classe OptionsForAssociationSelect est dans lib
def options_for_natures(period)
  [OptionsForAssociationSelect.new('Recettes', :recettes_accounts, period), OptionsForAssociationSelect.new('Dépenses',:depenses_accounts, period)]
end





end