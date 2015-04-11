module Admin::MasksHelper
 
  
  
  class OptionsForGroupedSelect
    attr_reader:title, :options

    def initialize(titre, names)
      @title=titre
      @options = names
    end

    
  end
  
    
  def options_for_mask_counterpart(organism)
    [OptionsForGroupedSelect.new('Banques', organism.bank_accounts.collect(&:nickname) << 'Chèque à l\'encaissement'),
      OptionsForGroupedSelect.new('Caisses', organism.cashes)]
      
  end
  
  # le but est d'obtenir ici les natures regroupées par livre d'appartenance
  # en mettant un data_id au label de regroupement.
  #
  # Ceci afin que le javascript associé puisse activer ou désactiver les groupes 
  # en fonction de la sélection du livre.
  # 
  # On utilise name dans ces formulaires car les masques sont valables 
  # pour plusieurs exercices. Il faut donc que la nature de l'écriture soit
  # trouvée à partir du nom de la nature et non de son id. 
  # 
  #
  def mask_nature_options(period, mask)
    org = period.organism
    body = "".html_safe
    org.in_out_books.collect do |book|
      mytag =  content_tag :optgroup, {:label=>book.title, 'data-id'=>book.id} do
        options_for_select(book.natures.order(:position).
            collect {|n| [n.name]}, mask.nature_name)
      end
      body.safe_concat mytag
    end 
    body
    
    
  end
  
  def etat(masque)
    masque.complete? ? 'Complet' : 'Partiel'
  end
  
  

end
