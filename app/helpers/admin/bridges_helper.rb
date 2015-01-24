module Admin::BridgesHelper
  
  # le but est d'obtenir ici les natures regroupées par livre d'appartenance
  # en mettant un data_id au label de regroupement.
  #
  # Ceci afin que le javascript associé puisse activer ou désactiver les groupes 
  # en fonction de la sélection du livre.
  # 
  # Cet aspect de la chose n'est vraiment utile que s'il y a plusieurs livres de 
  # recettes; ce qui est plutôt une exception. D'où la condition qui cré un optgroup 
  # s'il y a plusieurs livres ou seulement des options si un seul livre de recettes.
  #
  def bridge_nature_options(period, bridge) 
    ibs = period.organism.income_books
    body = "".html_safe
    mytag = ''
    if ibs.count > 1
      ibs.collect do |book|
        mytag =  content_tag :optgroup, {:label=>book.title, 'data-id'=>book.id} do
          options_for_select(book.natures.collect {|n| [n.name]}, bridge.nature_name)
        end
        body.safe_concat mytag
      end 
    else
      mytag =  options_for_select(ibs.first.natures.collect {|n| [n.name]}, bridge.nature_name)
      body.safe_concat mytag
    end
    
    body
    
    
  end
  
  
  
end
