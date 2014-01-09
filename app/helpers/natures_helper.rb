module NaturesHelper

  # le but est d'obtenir ici les natures regroupées par livre d'appartenance
  # en mettant un data_id au label de regroupement.
  #
  # Ceci afin que le javascript associé puisse activer ou désactiver les groupes 
  # en fonction de la sélection du livre.
  #
  # Comme je suis dans une fenêtre modale pour des new et non des édit, je n'ai 
  # pas à gerer la valeur 'selected' lors de l'affichage
  def modal_nature_options(period)
    org = period.organism
    body = "".html_safe
    org.in_out_books.collect do |book|
      mytag =  content_tag :optgroup, {:label=>book.title, 'data-id'=>book.id} do
        options_for_select(book.natures.collect {|n| [n.name, n.id]})
      end
      body.safe_concat mytag
    end 
    body
    
    
  end


end
