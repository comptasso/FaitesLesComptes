module Admin::MasksHelper
 
  
  
  class OptionsForGroupedSelect
    attr_reader:title, :options

    def initialize(titre, names)
      @title=titre
      @options = names
    end

    
  end
  
  # Petite classe utilitaire pour avoir une collection de natures 
  # dans le form de Mask.
  # 
  # Voir la méthode options_for_mask_natues pour l'utilisation de cette class
  # 
  #  Dans le form, il suffit de faire 
  #  :collection => options_for_mask_natures(@organism),
  #     :as => :grouped_select, :group_method => :options, :group_label_method=> :title 
  #     
  #  pour que l'association et les regroupements soient faits. 
  #  title donnera le titre des regroupements et options la liste des options.
  #  
  #  Dans le cas présent, il n'y a pas besoin d'utiliser les options label_method
  #  et value_method car on remplit le select avec le texte de l'option (le nom des 
  #  méthodes).
  #
  class OptionsForMaskNatureSelect
    attr_reader:title

    def initialize(titre, model, action)
      @title=titre
      @model=model
      @action = action
    
    end

    def options
      @model.natures.send(@action).collect(&:name).uniq
    end

  end

  
  def options_for_mask_natures(organism)
    [OptionsForMaskNatureSelect.new('Recettes', organism, :recettes),
      OptionsForMaskNatureSelect.new('Dépenses', organism, :depenses)]
  end
  
  def options_for_mask_counterpart(organism)
    [OptionsForGroupedSelect.new('Banques', organism.bank_accounts.collect(&:nickname) << 'Chèque à l\'encaissement'),
      OptionsForGroupedSelect.new('Caisses', organism.cashes)]
      
    end
  
  

end
