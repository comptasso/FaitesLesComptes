module Compta::WritingsHelper
  # retourne 'debit' si c'est une ligne de débit
  # et 'credit' dans le cas contraire
  def class_style(compta_line)
    compta_line.credit == 0 ? 'debit' : 'credit'
  end
end
