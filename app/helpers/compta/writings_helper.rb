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



end
