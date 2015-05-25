# coding: utf-8

module Compta::WritingsHelper
  # retourne 'debit' si c'est une ligne de débit
  # et 'credit' dans le cas contraire
  def class_style(compta_line)
    compta_line.credit == 0 ? 'debit' : 'credit'
  end
  
  # Méthode utilisée pour retirer les lignes non voulues lorsqu'on utilise le 
  # bouton + dans la saisie d'écriture. Appelé par add_line.js.erb
  # 
  # En effet, le partiel est un formulaire simple_form_for dont on ne veut 
  # garder que la partie correspondant à la ligne de saisie de compta_line
  # 
  # Il est apparu plus simple de construire le form avec les méthodes classiques
  # et de retirer quelques lignes plutôt que de construire les 3 champs voulus.
  # 
  def new_compta_line_to_add(texte)
    # lines = texte.split('\n')
    # trouver la ligne qui contient form-inputs
    debut = 0
    texte.each_line do |l|
      debut += 1 
      break if /.*form-inputs.*/.match(l)
    end 
    # ne garder que les lignes entre celle-la
    res = texte.split("\n")
    res = res.slice(debut..-3)
    res.join("\n").html_safe
   
  end

  

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
  def compta_line_actions(book, writing)
    html =''
    # if writing.od_editable? || writing.an_editable?
    if (book.type == 'OdBook' && !writing.type)  || book.type =='AnBook' 
      
      unless writing.locked_at
        html += icon_to 'modifier.png', edit_compta_book_writing_path(book, writing)
        html += icon_to('supprimer.png', compta_book_writing_path(book, writing), :method=>:delete, data:{confirm:'Etes vous sûr ?'})
        html += icon_to('verrouiller.png', lock_compta_book_writing_path(book, writing, :mois=>@mois, :an=>@an), :method=>:post)
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
