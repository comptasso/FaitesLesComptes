# coding: utf-8

require 'strip_arguments'

# Writing représente des écritures dans la comptabilité
#
# Writing enregistre les informations communes à une écriture telle que la date
# le book, la référence, le libellé.
#
# Writing a des compta_lines qui enregistre les informations spécifiques aux lignes
# comptables, à savoir, le numéro de compte, le montant débit ou crédit.
#
# Comme une écriture est indissociable de ses compta_lines, on utilise accept_nested_attributes.
#
# Une écriture doit bien sur être équilibrée (balanced?).
#
# Trois scope viennent faciliter l'usage du modèle :
# - period pour filter sur l'exercice
# - mois pour filtrer sur un mois donné (on utilise une date quelconque comme paramètre)
# - unlocked pour identifier toutes les écritures qui ne sont pas verrouillées
#   sachant que le verrou (locked) est placé sur chaque compta_lines
#
# Chaque écriture de recettes ou de dépenses a pour contrepartie une compta_line
# de classe 5 (soit un compte bancaire, soit une caisse). Cette ligne est appelée support_line
# et accessible par la méthode du même nom.
# 
# Deux champs bridge_id et bridge_type permettent de faire le lien avec des modules
# extérieurs. Ils ont été ajoutés pour le module Adhérent. Ainsi un payement 
# enregistré dans ce module génère une écriture qui enregistre en bridge_type Adherent
# et en bridge id l'id du payement qui est à l'origine de cette écriture.
#
class Writing < ActiveRecord::Base
  include Utilities::PickDateExtension # apporte les méthodes pick_date_for

  pick_date_for :date

  # book_id est nécessaire car des classes comme check_deposit ont besoin de
  # créér une écriture en remplissant le champ book_id
  attr_accessible :date, :date_picker, :narration, :ref, :compta_lines_attributes, :book_id, 
    :bridge_id, :bridge_type

  belongs_to :book
 
  has_many :compta_lines, :dependent=>:destroy
  alias children compta_lines

  strip_before_validation :narration, :ref 
  
  validates :book_id,  presence:true
  validates :date, presence:true
  validates :date, :within_period=>true, :nested_period_coherent=>{:nested=>:compta_lines, :fields=>[:nature, :account]} , :unless => 'date.nil?'
  validates :compta_lines, presence:true, :two_compta_lines_minimum=>true
  validates :narration, :format=>{with:NAME_REGEX}, :length=>{:maximum=>60}
  validates :ref, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}, :allow_blank=>true
  
  validate :balanced?
  # les écritures dans le livre de report à nouveau doivent avoir le premier jour
  # de l'exercice comme date
  validate :period_start_date, :if=> lambda {book.type == 'AnBook'}
  

  accepts_nested_attributes_for :compta_lines, :allow_destroy=>true

  default_scope order('date ASC')
  
  scope :period, lambda {|p| where('date >= ? AND date <= ?', p.start_date, p.close_date)}
  scope :mois, lambda { |date| where('date >= ? AND date <= ?', date.beginning_of_month, date.end_of_month) }
  # scope :not_transfer, where('type != ?', 'Transfer')
  
  scope :unlocked, joins(:compta_lines).where('locked = ?', false).uniq
  scope :no_type, where('writings.type IS NULL')
  scope :an_od_book, joins(:book).where('books.type'=>['OdBook', 'AnBook'])
  scope :compta_editable, unlocked.an_od_book.no_type
  

  # Fait le total des debit des compta_lines
  # la méthode utilisée permet de neutraliser les nil éventuels
  # utile notamment pour les tests de validité
  def total_debit
    compta_lines.inject(0) {|tot, cl| cl.debit ? tot + cl.debit  : tot}
  end

  # Fait le total des debit des compta_lines
  # la méthode utilisée permet de neutraliser les nil éventuels
  def total_credit
    compta_lines.inject(0) {|tot, cl| cl.credit ? tot + cl.credit  : tot}
  end

  # trouve l'exercice correspondant à la date de l'écriture
  def period
    book.organism.find_period(date) rescue nil 
  end

  # Support renvoie le long_name du compte de la première ligne
  # avec un compte de classe 5 de l'écriture.
  #
  # nil si pas de support_line pour cette ériture
  def support
    s = support_line
    s.account.long_name if s && s.account
  end

  # support_line renvoie la première ligne de classe 5 de l'écriture.
  # Certaines écritures n'ont pas de support_line (notamment les écritures d'OD).
  # Dans ce cas renvoie nil
  def support_line
    s = compta_lines.select {|cl| cl.account && cl.account.number =~ /^5.*/}
    s.first if s
  end
  
  # retourne le mode de payment associé à cette écriture
  def payment_mode
    support_line.payment_mode if support_line
  end

  # indique si une écritue est équilibrée ou non
  # ajoute une erreur si déséquilibrée
  def balanced?
    return false if compta_lines.size == 0 # Même s'il y a un validator two_compta_lines,
    # il ne s'exécute pas forcément avant celui ci d'où l'intérêt d'un test.
    if total_credit != total_debit
      logger.debug "Total débit : #{total_debit} - Total credit : #{total_credit}"
      errors.add(:base, 'Ecriture déséquilibrée')
      false
    else
      true
    end
  end

  # lock verrouille toutes les lignes de l'écriture
  def lock
    Writing.transaction do
      compta_lines.each do |cl|
        unless cl.locked?
          cl.update_attribute(:locked, true)
        end
      end
    end
  end

  # Une écriture est verrouillée dès lors qu'une seule de ses lignes l'est
  def locked?
    compta_lines.where('locked = ?', true).any?
  end

  # Une ligne n'est od_editable que s'il est appartient à un livre d'OD,
  # est non verrouillée, mais aussi n'est pas une écriture générée par
  # la partie saise/consult.
  #
  #  En l'occurence, il peut y avoir deux cas, c'est un Transfer ou une
  #  Remise de chèques.
  #
  # Ces écritures doivent en effet être modifiées dans les vues qui leur sont réservées.
  #
  def od_editable?
    !locked? && book.type == 'OdBook' && type == nil
  end

  # Une ligne est an_editable si elle appartient au livre d'AN
  # et qu'elle n'est pas verrouillée.
  #
  # On rajoute type == nil par analogie avec od_editable mais
  # c'est une condition toujours remplie
  #
  def an_editable?
    !locked? && book.type == 'AnBook' && type == nil
  end

  # seules les lignes qui sont od_editable ou an_editable sont compta_editable
  # utilisée dans la vue et le controleur selection
  def compta_editable?
    od_editable? || an_editable?
  end
  
  # une ligne est editable? si toutes ses compta_lines sont editable?
  def editable?
    compta_lines.all? {|cl| cl.editable?}
  end

  protected

  # méthode de validation utilisée pour vérifier que les écritures sur le 
  # journal d'A Nouveau sont passées au premier jour de l'exercice
  def period_start_date
    p = book.organism.find_period(date)
    if date != p.start_date
      errors.add(:date, 'Doit être le premier jour')
      false
    else
      true
    end
  end

  

 
  
end
