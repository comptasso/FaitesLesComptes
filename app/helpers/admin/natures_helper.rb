# coding: utf-8
module Admin::NaturesHelper
# Petite classe pour construire la sélection des comptes associés à une nature
# Cette classe permet de construire un groupe d'options pour la nature
# Usage : OptionsForNatureSelect('Recettes', :recettes, period)
# Le type peut être :recettes ou :depenses
class OptionsForAccountSelect
  attr_reader:name

  def initialize(titre, type, period)
    @name=titre
    @object=period
    @type=type
  end

  def options
    @object.send(@type)
  end

end


# Helper permettant de construire les options pour le form
#
def options_for_natures(period)
  [OptionsForAccountSelect.new('Recettes', :recettes_accounts, period), OptionsForAccountSelect.new('Dépenses',:depenses_accounts, period)]
end


# class auxiliaire pour permettre d'avoir l'accent dans la collection radio button
class Depenses

  def name
    'Dépenses'
  end

  def value
    false
  end

end

class Recettes
  def name
    'Recettes'
  end

  def value
    true
  end


end

def radio_options_for_nature
  [Recettes.new, Depenses.new]
end



end