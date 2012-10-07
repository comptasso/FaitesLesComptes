# coding: utf-8

# une InOutWriting est un type d'écriture qui permet d'enregistrer des lignes de dépenses et
# de recettes
class  InOutWriting < Writing

  
  # revoie la ligne de recettes ou de dépenses de cette écriture
  def in_out_line
    compta_lines.select { |l| l.nature_id != nil }.first
  end

  def counter_line
    compta_lines.select { |l| l.nature_id == nil }.first
  end

  def support
    counter_line.account.long_name if counter_line && counter_line.account
  end
end
