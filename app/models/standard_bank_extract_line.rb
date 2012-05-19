# -*- encoding : utf-8 -*-

# le modèle BanExtractLine représente une ligne d'un relevé bancaire.
# Cette ligne peut correspondre à une ligne d'un livre de recettes ou de dépenses 
# du moment qu'il s'agit d'une opération bancaire (pas d'espèces évidemment).
# Par exemple un prélèvement ou un virement
# Mais ce peut être aussi une remise de chèque.qui elle même renvoie à plusieurs lignes.
#
# Le modèle a des sous classes : la seule actuellement est check_deposit_bank_extract_line
# et est représenté par une table comme champs date, position, type, bank_extract_id
# et check_deposit_id (ce dernier champ ne servant que pour la sous classe
# CheckDepositBankExtractLine
#
# La méthode de classe has_many est surchargée dans CheckDepositBankExtractLine
# pour pouvoir renvoyer les lines associées
#
# Une relation HABTM est définie avec lines, permettant d'avoir une ligne de relevé
# bancaire qui correspond à plusieurs lignes d'écriture (ex péages regroupés
# par semaine par les sociétés d'autoroute mais dont les dépenses sont enregistrées
# ticket par ticket
# Ou à l'inverse une ligne de dépenses qui aurait donné lieu à une opération bancaire
# détaillée en deux lignes.
#
# Acts as list permet d'utiliser le champ position pour ordonner les lignes du relevé
#

class StandardBankExtractLine < BankExtractLine
  

 #  after_save :link_to_source

  #  before_destroy :remove_link_to_source
  validate :not_empty

  after_initialize :prepare_datas

  # lock_line verrouille la ligne d'écriture. Ceci est appelé par bank_extract (after_save)
  # lorsque l'on verrouille le relevé
  # Seules les lignes d'écritures sont verrouillées (pas les remises de chèques) car
  # il s'agit seulement de se conformer à la législation qui impose de ne plus
  # pouvoir modifier des écritures après inscription au journal.
  # En fait il faut aussi verrouiller les lignes d'écritures qui ont nourri une remise de chèque
  def lock_line
    # si c'est une ligne qui n'est pas déja verrouillée, on la verrouille
    self.line.update_attribute(:locked,true) if (self.line_id && !self.line.locked)
    # si c'est une remise de chèque on verrouille les lignes correspondantes
    self.check_deposit.checks.each {|l| l.update_attribute(:locked, true)} if self.check_deposit_id
  end

  # debit fait le total débit des lignes.
  def debit
    lines.sum(:debit)
  end

  # Retourne le total des crédits des lignes associées
  def credit
    lines.sum(:credit)
  end

  # regorup prend une standard_bank_extract_line comme argument
  # et la fusionne avec l'instance.
  #
  # Cela signifie que l'on tranfère les lignes de bel à self.
  # puis que l'on supprime la ligne bel.
  #
  def regroup(bel)
    bel.lines.each do |l|
      bel.lines.delete(l)
      lines << l
    end
    save
    bel.destroy
  end

  

  def prepare_datas
    raise 'StandardBankExtractLine sans ligne' if lines.empty?
    self.date ||= lines.first.line_date # par défaut on construit les infos de base
    @payment= lines.first.payment_mode # avec la première ligne associée
    @narration = lines.first.narration
    # TODO blid est-il utils
    @blid= "line_#{lines.first.id}" if lines.count == 1 # blid pour bank_line_id
  end
#
  private

  def not_empty
    if lines.empty?
      errors.add(:lines, 'cant exist without lines')
      false
    else
      true
    end
  end

 

  #  # appelée par after_save, a pour effet de remplir le champ bank_extract_id qui
  #  # TODO check s'il peut y avoir des lignes rattachées à un compte qui nécessite cette étape
  #  # Oui pour les remises de chèques mais pour les autres ???
  #  # associe la ligne au relevé de compte (en fait c'est normalement peu utile car
  #  # lors de l'enregistrement des lignes, le compte bancaire est déja rempli
  #  def link_to_source
  #    self.lines.each {|l| l.update_attribute(:bank_extract_id, self.bank_extract_id) }
  #  end

  #  def remove_link_to_source
  #    self.line.update_attribute(:bank_extract_id, nil) if self.line_id
  #    self.check_deposit.update_attribute(:bank_extract_id, nil) if self.check_deposit_id
  #  end

   
end
