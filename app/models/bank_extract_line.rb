# coding: utf-8


# La classe sert de mère pour les différents types de BankExtractLine avec une
# seule table (STI)
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

  # FIXME - voir note sur la méthode not_empty
  # before_save :not_empty
  before_destroy :remove_from_list  #est défini dans le plugin acts_as_list

 
  # chainable indique si le bank_extract_line peut être relié à son suivant
  # Ce n'est possible que si
  #  - ce n'est pas une remise de chèque
  #  - ce n'est pas le dernier
  #  - ils ne sont du même sens.
  #  - le suivant n'est pas une remise de chèque
  #
  def chainable?
    # return false si c'est une remise de chèque
    return false unless lower_item
    return false if (lower_item.debit == 0 && self.debit != 0) || (self.credit != 0 && lower_item.credit == 0)
    # return false si le suivant est une remise de chèque
    true
  end


  # appelé par before_add pour s'assurer que la ligne n'est pas déja rattachée
  # à une ligne d'un relevé bancaire
  def not_already_included(line)
    if line.bank_extract_lines.count > 0
      logger.warn "tried to include line #{line.id} which was already included in a bank_extract_line"
      raise ArgumentError
    end
  end

  # lock_line verrouille les lignes d'écriture associées à une bank_extract_line,
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

  # regorup prend une standard_bank_extract_line comme argument
  # et la fusionne avec l'instance.
  #
  # Cela signifie que l'on tranfère les lignes de l'argument à self.
  # puis que l'on supprime l'enregistrement correspondant à l'argument par la ligne bel.destroy.
  #
  def regroup(bel)
    bel.compta_lines.all.each do |l|
      bel.compta_lines.delete(l) # car le validator impose que la ligne ne soit pas déjà attaché à
      # un bank_extract_lines
      compta_lines << l
    end
    if Rails.env == 'test'
      puts errors.messages unless valid?
      compta_lines.each {|cl| puts "ComptaLine #{cl.debit} #{cl.credit} #{cl.errors.messages}" unless cl.valid?}
    end
    save
    puts "Nombre de lignes #{bel.compta_lines.count}" unless valid? 
    bel.destroy
    
  end

  # degroup décompose l'instance ayant plusieurs lignes en autant
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
    grp.insert(0,self) 
    grp
  end


  # TODO à mettre dans private
  def prepare_datas
    #raise 'StandardBankExtractLine sans ligne'
    unless compta_lines.empty?
      self.date ||= compta_lines.first.date # par défaut on construit les infos de base
      @payment= compta_lines.first.payment_mode # avec la première ligne associée
      @narration = compta_lines.first.narration
      # TODO blid est-il utile ?
      @blid= "line_#{compta_lines.first.id}" if compta_lines.count == 1 # blid pour bank_line_id
    end

  end


  private

  # vérifie que la BankExtractLine n'est pas vide.
  #
  # Cette condition ne s'applique pas si on veut effacer l'enregistrement.
  #
  # FIXME - Problème avec la version de acts_as_list 0.1.9
  # car ce plugin appelle self.reload dans son before_destroy.
  # (il semble que cette évolution ait été faite pour permettre l'utilisation
  # de accepts_nested_attributes_for mais du coup le before_save :not_empty devient
  # problématique
  #
  # .
#  def not_empty
#    if compta_lines.empty?
#      Rails.logger.warn 'Tentative d enregistrer une bank_extract_line sans compta_lines'
#      return false
#    end
#  end



  
end
