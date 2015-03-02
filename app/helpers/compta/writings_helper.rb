# coding: utf-8

module Compta::WritingsHelper
  # retourne 'debit' si c'est une ligne de débit
  # et 'credit' dans le cas contraire
  def class_style(compta_line)
    compta_line.credit == 0 ? 'debit' : 'credit'
  end



  # Cette méthode helper ajoute une ligne de saisie d'une ComptaLine. 
  # l'index utilisé new_compta_lines sera remplacé par javascript en un autre identifiant lié au 
  # temps.
  # Voir le railscasts#197.
  def link_to_add_fields(name, f)
    fields = f.fields_for(:compta_lines, ComptaLine.new, :child_index => "new_compta_lines") do |builder|
      render('compta_line_fields', :builder => builder)
    end
    link_to_function(name, "add_fields(this, 'compta_lines', \"#{escape_javascript(fields)}\")")
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
  #
  def compta_line_actions(book, writing)
    html =''
    # if writing.od_editable? || writing.an_editable?
    if (book.is_a?(OdBook) && !writing.type)  || book.is_a?(AnBook) 
      unless verrouillee?(writing)
        html += icon_to 'modifier.png', edit_compta_book_writing_path(book, writing)
        html += icon_to('supprimer.png', compta_book_writing_path(book, writing), :method=>:delete, data:{confirm:'Etes vous sûr ?'})
        html += icon_to('verrouiller.png', lock_compta_book_writing_path(book, writing, :mois=>@mois, :an=>@an), :method=>:post)
      end
    else
      unless verrouillee?(writing)
        html += image_tag('icones/nb_verrouiller.png',
          title:'Le verrouillage de cette écriture doit se faire dans la partie Saisie/Consult par pointage du compte bancaire et/ou de la caisse')
      end
    end
    
    html.html_safe
  end
  
  
  protected
  
  # refactorisation ; à n'utiliser que si writing a été obtenue avec 
  # les compta_lines inclues. Sinon, utiliser les méthodes de Writing
  def verrouillee?(writing)
    writing.compta_lines.detect {|cl| cl.locked }
  end



end
