# coding: utf-8
require 'options_for_association_select'

module Admin::NaturesHelper


  # Helper permettant de construire les options pour le champ account du formulaire
  # La classe OptionsForAssociationSelect est dans lib
  # 
  def comite_options_for_natures(period)
    Sector.all.collect do |s|
      [OptionsForAssociationSelect.new(nat_group_title('Recettes', s),
          :recettes_accounts, period,
          s.id, {'data-type'=>'IncomeBook'}),
        OptionsForAssociationSelect.new(nat_group_title('Dépenses', s),
          :depenses_accounts, period,
          s.id, {'data-type'=>'OutcomeBook'}) 
      ]
    end.flatten
  end
  
  protected
  
  def nat_group_title(titre, sector = nil)
    @organism.sectored? ? "#{titre} #{sector.name}" : titre
  end





end