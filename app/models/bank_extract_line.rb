# coding: utf-8


# Le modèle BanExtractLine représente une ligne d'un relevé bancaire.
#
# Cette ligne peut correspondre à une ligne d'un livre de recettes ou de dépenses
# du moment qu'il s'agit d'une opération bancaire (pas d'espèces évidemment).
# Par exemple un prélèvement ou un virement
# Mais ce peut être aussi une remise de chèque.qui elle même renvoie à plusieurs lignes.
#
#
#
# Acts as list permet d'utiliser le champ position pour ordonner les lignes du relevé
#
class BankExtractLine < ActiveRecord::Base 

  attr_accessible :compta_lines

  belongs_to :bank_extract

  belongs_to :compta_line 
 
  acts_as_list :scope => :bank_extract
   
  attr_accessible :compta_line_id, :bank_extract_id, :date, :narration, :debit, :credit
  
  delegate :narration, :debit, :credit, :date, :payment_mode,  :to=>:compta_line
  
  validates :bank_extract_id, :compta_line_id, :presence=>true
  validates :compta_line_id, :uniqueness=>true

  # Lock_line verrouille les lignes d'écriture associées à une bank_extract_line,
  # ce qui entraîne également le verrouillage de tous les siblings et éventuellement
  # des chèques si la compta_line est une remise de chèque.
  # 
  # Cette méthode est appelée par bank_extract (after_save)
  # lorsque l'on verrouille le relevé
  #
  def lock_line
    compta_line.lock
  end

end
