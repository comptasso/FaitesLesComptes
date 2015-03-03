# coding: utf-8

module Compta::SelectionsHelper
 
  # Rédefinit les actions disponibles pour l'affichage des writings dans compta
  #
  # Les règles sont les suivantes :
  # - lorsque le livre est OD
  # -- des cadenas de couleur pour les lignes entrées directement dans le livre OD
  # -- des cadenas noir et blance pour les lignes Transfert/ et Remises de Chèques
  # - lorsque le livre n'est pas OD
  # -- les icones cadenas ne peuvent être que noir et blanc
  # -- et il ne peut y avoir que cette icone
  # 
  # od_editable? et an_editable? (définies dans writing.rb) créent des requêtes
  # inutiles car on a obtenu des writings avec leur compta_lines associées.
  # Donc on traite les tests sur les données déjà en mémoire.
  # cl.type est là pour identifier les écritures qui sont des transferts et 
  # des remises de chèques.
  # 
  # La méthode est testée dans la vue index
  #
  def compta_line_selections_actions(writing)
    html =''
    wb = writing.book
    # if writing.od_editable? || writing.an_editable?
    if (wb.type == 'OdBook' && !writing.type)  || wb.type =='AnBook' 
      
      unless writing.locked_at
        html += icon_to 'modifier.png', edit_compta_book_writing_path(wb, writing)
        html += icon_to('supprimer.png', compta_book_writing_path(wb, writing), :method=>:delete, data:{confirm:'Etes vous sûr ?'})
        html += icon_to 'verrouiller.png',
          lock_compta_period_selection_path(@period, writing),
          :method=>:post, remote:true unless writing.locked?
      end
      
    else
      
      unless writing.locked_at
        html += image_tag('icones/nb_verrouiller.png',
          title:'Le verrouillage de cette écriture doit se faire dans la partie Saisie/Consult par pointage du compte bancaire et/ou de la caisse')
      end
      
    end
    
    html.html_safe
  end
 
  



end
