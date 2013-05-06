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
  # -- des cadenas de couler pour les lignes entrées directement dans le livre OD
  # -- des cadenas noir et blance pour les lignes Transfert/ et Remises de Chèques
  # - lorsque le livre n'est pas OD
  # -- les icones cadenas ne peuvent être que noir et blanc
  # -- et il ne peut y avoir que cette icone
  #
  def compta_line_actions(book, writing)
    html =''
    if writing.od_editable? || writing.an_editable?
      html += icon_to 'modifier.png', edit_compta_book_writing_path(book, writing)
      html += icon_to('supprimer.png', compta_book_writing_path(book, writing), :method=>:delete, :confirm=>'Etes vous sur ?')
      html += icon_to('verrouiller.png', lock_compta_book_writing_path(book, writing, :mois=>@mois, :an=>@an), :method=>:post)
    else
      html += image_tag('icones/nb_verrouiller.png', title:'Le verrouillage de cette écriture doit se faire dans la partie Saisie/Consult par pointage du compte bancaire et/ou de la caisse') unless writing.locked?
    end
    html.html_safe
  end



end
