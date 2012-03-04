# coding: utf-8

module CheckDepositsHelper

  def button_for_check(check)  
    if check.bank_extract_id.nil?
      button_to "Ajouter", add_check_bank_account_check_deposit_path(@bank_account, @check_deposit), remote: true, :line_id=>check.id
    else
      button_to "Retirer", remove_check_bank_account_check_deposit_path(@bank_account, @check_deposit), remote:true, :line_id=>check.id
    end
  end
end


# Petite classe pour construire la sélection des chèques d'une remise de chèques
# Cette classe permet de construire un groupe d'options pour la remise
# Usage : OptionsForSelect('Chèques inclus', :target, check_deposit)
# Le type peut être target (déja dans la remise de chèques) ou :tank (le réservoir)
class OptionsForSelect
  attr_reader:name

  def initialize(titre, type, check_deposit)
    @name=titre
    @check_deposit=check_deposit
    @type=type
  end

  def checks
    if @type == :target
      @check_deposit.target_checks
    elsif @type == :tank
      @check_deposit.tank_checks
    else
      raise 'Type inconnu'
    end
  end

  
end


# Helper permettant de construire les options pour le form
#
def options_for_checks(check_deposit)
  [OptionsForSelect.new('Déja inclus', :target, check_deposit), OptionsForSelect.new('Non inclus',:tank, check_deposit)]
end


