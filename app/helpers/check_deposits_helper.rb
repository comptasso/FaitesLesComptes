# coding: utf-8

# Petite classe pour construire la sélection des chèques d'une remise de chèques
# Cette classe permet de construire un groupe d'options pour la remise
# 
# Usage : OptionsForCheckSelect('Chèques inclus', :target, check_deposit)
# Le type peut être target (déja dans la remise de chèques) ou :tank (le réservoir)
#
# Cela permet ensuite d'être utilisé dans un formulaire avec liste de sélection et groupe
# d'options. Il suffit de lister les différentes groupes (voir plus bas, la méthode options_for_checks
# pour un exemple.
#
# Et dans le formulaire utiliser une collection avec comme group_label_méthod :name
# et group_method :checks
#
class OptionsForChecksSelect
  attr_reader :name

  def initialize(name, type, check_deposit, sector)
    @name = name
    @check_deposit = check_deposit
    @type = type
    @sector = sector
  end

  def checks
    if @type == :target
      @check_deposit.checks
    elsif @type == :tank
      CheckDeposit.pending_checks(@sector)
    else
      raise 'Type inconnu'
    end
  end

  
end

module CheckDepositsHelper

  # Helper permettant de construire les options pour le form
  #
  def options_for_checks(check_deposit, sector)
    [OptionsForChecksSelect.new('Déja inclus', :target, check_deposit, sector), OptionsForChecksSelect.new('Non inclus',:tank, check_deposit, sector)]
  end



end

