# coding: utf-8


# La classe sert de mère pour les différents types de BankExtractLine avec une
# seule table (STI)
#
# En pratique on n'utilise pas les possibilité de STI
# TODO retirer le champ type
# TODO après modification du avascript de pointage, il a été décidé d'abandonner
# la logique habtm avec les comptalines. 
# Il faudrait donc modifier les tables et revenir à une logique classique.
# de relation has_one, belongs_to. La contrepartie étant qu'on ne peut plus 
# associer plusieurs lignes de compta à une ligne de relevé et vice-versa.
# Il n'y aura plus qu'une logique un pour un (ce qui devrait convenir pour 
# une compta simplifiée).
#
# Le modèle BanExtractLine représente une ligne d'un relevé bancaire.
#
# Cette ligne peut correspondre à une ligne d'un livre de recettes ou de dépenses
# du moment qu'il s'agit d'une opération bancaire (pas d'espèces évidemment).
# Par exemple un prélèvement ou un virement
# Mais ce peut être aussi une remise de chèque.qui elle même renvoie à plusieurs lignes.
#

#
# Une relation HABTM est définie avec compta_lines, permettant d'avoir une ligne de relevé
# bancaire qui correspond à plusieurs lignes d'écriture (ex péages regroupés
# par semaine par les sociétés d'autoroute mais dont les dépenses sont enregistrées
# ticket par ticket.
#
# Ou à l'inverse une ligne de dépenses qui aurait donné lieu à une opération bancaire
# détaillée en deux lignes sur le relevé.
#
# Acts as list permet d'utiliser le champ position pour ordonner les lignes du relevé
#
class BankExtractLine < ActiveRecord::Base 

  attr_accessible :compta_lines

  belongs_to :bank_extract

  belongs_to :compta_line 
 #   :before_add=>:not_already_included,
 #   :uniq=>true # pour les rapprochements bancaires

  acts_as_list :scope => :bank_extract
 
  # TODO modifier payment en payment_mode pour utiliser delegate
  
  attr_accessible :compta_line_id, :bank_extract_id
  
  delegate :narration, :debit, :credit, :date, :to=>:compta_line
  
  validates :bank_extract_id, :compta_line_id, :presence=>true
  validates :compta_line_id, :uniqueness=>true

  def payment
    compta_line.payment_mode
  end

 
  


  
  # Lock_line verrouille les lignes d'écriture associées à une bank_extract_line,
  # ce qui entraîne également le verrouillage de tous les siblings.
  # Ceci est appelé par bank_extract (after_save)
  # lorsque l'on verrouille le relevé
  #
  def lock_line
    compta_line.lock
    
    # si l est une remise de chèque il faut aussi verrouiller les écritures correspondantes
      
    # TODO logique à mettre dans le modèle ComptaLine
    if compta_line.check_deposit_id
      cd = compta_line.check_deposit
      cd.checks.each {|l| l.lock}
    end
    
  end

  
  



  protected

  # Indique si c'est une remise de chèque en vérifiant qu'aucun ligne n'en
  # est une.
  #
  # En pratique une remise de chèque ne peut avoir qu'une ligne mais
  # on ne part pas de cette certitude. On teste donc toutes les lignes
  
# TODO : UTILISE ?
  def check_deposit?
    compta_lines.each do |cl|
      return true if cl.check_deposit_id
    end
    false
  end


  private
  
  

  # Vérifie que la BankExtractLine n'est pas vide.
  #
  # .
  def not_empty
    unless compta_line
      Rails.logger.warn 'Tentative d enregistrer une bank_extract_line sans compta_lines'
      errors.add(:base, 'empty')
    end
  end

  # Appelé par before_add pour s'assurer que la ligne n'est pas déja rattachée
  # à une ligne d'un relevé bancaire
  def not_already_included(line)
    if line.bank_extract_lines.count > 0
      logger.warn "tried to include line #{line.id} which was already included in a bank_extract_line"
      raise ArgumentError, 'La ligne est déja inclue'
    end
  end

  



  
end
