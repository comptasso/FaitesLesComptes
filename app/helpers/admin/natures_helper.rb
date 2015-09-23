# coding: utf-8
require 'options_for_association_select'

module Admin::NaturesHelper


  # Helper permettant de construire les options pour le champ account du formulaire
  # La classe OptionsForAssociationSelect est dans lib
  #
  def comite_options_for_natures(period)
    @organism.sectors.collect do |s|
      nat_associations(period, s)
    end.flatten
  end
  
  def comite_options_for_natures_without_commun(period)
    @organism.sectors.reject{|se| se.name == 'Commun'}.collect do |s|
      nat_associations(period, s)
    end.flatten
  end
  
  
  
  
  
  protected
  
  def nat_associations(period, sect)
    [OptionsForAssociationSelect.new(nat_group_title('Recettes', sect),
          :recettes_accounts, period,
          sect.id, {'data-type'=>'IncomeBook'}),
        OptionsForAssociationSelect.new(nat_group_title('Dépenses', sect),
          :depenses_accounts, period,
          sect.id, {'data-type'=>'OutcomeBook'})]
  end

  def nat_group_title(titre, sector = nil)
    @organism.sectored? ? "#{titre} #{sector.name}" : titre
  end





end
