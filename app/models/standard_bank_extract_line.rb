# -*- encoding : utf-8 -*-

# Classe destinée à enregistrer les lignes standard de dépenses et de recettes
#
class StandardBankExtractLine < BankExtractLine
  

 #  after_save :link_to_source

  #  before_destroy :remove_link_to_source
  validate :not_empty

  after_initialize :prepare_datas

  # lock_line verrouille la ligne d'écriture. Ceci est appelé par bank_extract (after_save)
  # lorsque l'on verrouille le relevé
  # 
  def lock_line
    self.lines.each {|l| l.update_attribute(:locked,true) unless l.locked? }
    # si c'est une remise de chèque on verrouille les lignes correspondantes
   # self.check_deposit.checks.each {|l| l.update_attribute(:locked, true)} if self.check_deposit_id
  end

  # Retourne le total débit des lignes associées.
  def debit
    lines.sum(:debit)
  end

  # Retourne le total crédit des lignes associées
  def credit
    lines.sum(:credit)
  end

  # regorup prend une standard_bank_extract_line comme argument
  # et la fusionne avec l'instance.
  #
  # Cela signifie que l'on tranfère les lignes de l'argument à self.
  # puis que l'on supprime l'enregistrement correspondant à l'argument.
  #
  def regroup(bel)
    bel.lines.each do |l|
      bel.lines.delete(l)
      lines << l
    end
    save
    bel.destroy
  end

  # degroup décompose l'instance ayant plusieurs lignes en autant
  # de StandardBankExtractLine qu'il y a de lignes.
  #
  # La position des différentes bels ainsi obtenue est contigue
  #
  # La méthode renvoie un tableau composé des bels nouvellement créées.
  # (la première étant self mais dépouillée de toutes ses lignes sauf une
  #
  def degroup
    return self if self.lines.size < 2
    pos = position
    grp = lines.offset(1).all.map do |l|
      lines.delete(l)
      new_bel = bank_extract.standard_bank_extract_lines.create!(lines:[l])
      new_bel.insert_at(pos + 1)
      new_bel
    end
    grp.insert(0,self)
    grp 
  end

  
  # TODO à mettre dans private
  def prepare_datas
   #raise 'StandardBankExtractLine sans ligne'
    unless lines.empty?
       self.date ||= lines.first.line_date # par défaut on construit les infos de base
       @payment= lines.first.payment_mode # avec la première ligne associée
       @narration = lines.first.narration
    # TODO blid est-il utile ?
       @blid= "line_#{lines.first.id}" if lines.count == 1 # blid pour bank_line_id
    end

  end

  
  private

  def not_empty
    if lines.empty?
      errors.add(:lines, 'cant exist without lines')
      false
    else
      true
    end
  end

   
end
