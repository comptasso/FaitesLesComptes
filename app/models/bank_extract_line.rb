# coding: utf-8


# La classe sert de mère pour les différents types de BankExtractLine avec une
# seule table (STI)
#
# En pratique on n'utilise pas les possibilité de STI
# TODO retirer le champ type
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

  belongs_to :bank_extract

  has_and_belongs_to_many :compta_lines, 
    :join_table=>:bank_extract_lines_lines,
    :association_foreign_key=>'line_id',
    :before_add=>:not_already_included,
    :uniq=>true # pour les rapprochements bancaires

  acts_as_list :scope => :bank_extract
 
  after_initialize :prepare_datas

  attr_reader :payment, :narration, :debit,  :credit

  validate :not_empty

  before_destroy :remove_from_list  #est défini dans le plugin acts_as_list

 
  # Chainable? indique si le bank_extract_line peut être relié à son suivant
  # Ce n'est possible que si
  #  - ce n'est pas le dernier
  #  - ils ne sont du même sens.
  #  - ce n'est pas une remise de chèque
  #  - le suivant n'est pas une remise de chèque
  #
  def chainable?
    return false unless lower_item
    return false if (lower_item.debit == 0 && self.debit != 0) || (self.credit != 0 && lower_item.credit == 0)
    return false if check_deposit? # c'est une remise de chèque
    return false if lower_item.check_deposit? # le suivant est une remise de chèque
    true
  end

  


  
  # Lock_line verrouille les lignes d'écriture associées à une bank_extract_line,
  # ce qui entraîne également le verrouillage de tous les siblings.
  # Ceci est appelé par bank_extract (after_save)
  # lorsque l'on verrouille le relevé
  #
  def lock_line
    compta_lines.each do |l|
      # verrouillage des siblings 
      l.lock
      # si l est une remise de chèque il faut aussi verrouiller les écritures correspondantes
      if l.check_deposit_id
        cd = l.check_deposit
        cd.checks.each {|l| l.lock}
      end
    end
  end

  # Retourne le total débit des lignes associées.
  def debit
    compta_lines.sum(:debit)
  end

  # Retourne le total crédit des lignes associées
  def credit
    compta_lines.sum(:credit)
  end

  # Regroup prend une standard_bank_extract_line comme argument
  # et la fusionne avec l'instance.
  #
  # Cela signifie que l'on tranfère les lignes de l'argument à self.
  # puis que l'on supprime l'enregistrement correspondant à l'argument par la ligne bel.destroy.
  #
  def regroup(bel)
    cls = bel.compta_lines.all
    BankExtractLine.transaction do
      bel.destroy
      cls.each {|cl| compta_lines << cl}
      if Rails.env == 'test'
        puts errors.messages unless valid?
        compta_lines.each {|cl| puts "ComptaLine #{cl.debit} #{cl.credit} #{cl.errors.messages}" unless cl.valid?}
      end
      save
    end
    
    
  end

  # Degroup décompose l'instance ayant plusieurs lignes en autant
  # de BankExtractLine qu'il y a de lignes.
  #
  # La position des différentes bels ainsi obtenue est contigue
  #
  # La méthode renvoie un tableau composé des bels nouvellement créées.
  # (la première étant self mais dépouillée de toutes ses lignes sauf une
  #
  def degroup
    return self if self.compta_lines.size < 2
    pos = position
    grp = compta_lines.offset(1).all.map do |l|
      compta_lines.delete(l)
      new_bel = bank_extract.bank_extract_lines.create!(:compta_lines=>[l])
      new_bel.insert_at(pos + 1)
      new_bel
    end
    grp.insert(0,self) # on rajoute self au groupe ainsi obtenu
    grp
  end


  protected

  # Indique si c'est une remise de chèque en vérifiant qu'aucun ligne n'en
  # est une.
  #
  # En pratique une remise de chèque ne peut avoir qu'une ligne mais
  # on ne part pas de cette certitude. On teste donc toutes les lignes
  def check_deposit?
    compta_lines.each do |cl|
      return true if cl.check_deposit_id
    end
    false
  end


  private
  
  # A partir des données de compta_lines, remplit quelques champs dynamiques
  # de la BankExtractLine
  def prepare_datas
    unless compta_lines.empty?
      clf = compta_lines.first
      self.date ||= clf.date # par défaut on construit les infos de base
      @payment= clf.payment_mode # avec la première ligne associée
      @narration = clf.narration
    end

  end

  # Vérifie que la BankExtractLine n'est pas vide.
  #
  # .
  def not_empty
    if compta_lines.empty?
      Rails.logger.warn 'Tentative d enregistrer une bank_extract_line sans compta_lines'
      errors.add(:base, 'empty')
    end
  end

  # Appelé par before_add pour s'assurer que la ligne n'est pas déja rattachée
  # à une ligne d'un relevé bancaire
  def not_already_included(line)
    if line.bank_extract_lines.count > 0
      logger.warn "tried to include line #{line.id} which was already included in a bank_extract_line"
      raise ArgumentError
    end
  end

  



  
end
