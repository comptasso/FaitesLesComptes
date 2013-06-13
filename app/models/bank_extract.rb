# -*- encoding : utf-8 -*-
require 'strip_arguments'
class BankExtract < ActiveRecord::Base
  include Utilities::PickDateExtension

  # utilise le module Utilities::PickDateExtension pour créer des virtual attributes
  # begin_date_picker et end_date_picker
  pick_date_for :begin_date, :end_date

  attr_accessible :reference, :begin_date, :end_date, :begin_sold, :total_debit,
    :total_credit, :begin_date_picker, :end_date_picker
  
  belongs_to :bank_account 
  has_many :bank_extract_lines, dependent: :destroy

  strip_before_validation :reference
  
  validates :reference, :format=>{with:NAME_REGEX}, :length=>{maximum:15}, :allow_blank=>true

  validates :begin_sold, :total_debit, :total_credit,:presence=>true, :numericality=>true, :two_decimals => true
  validates :begin_sold, :total_debit, :total_credit, :begin_date, :end_date , :cant_edit=>true, :if=>Proc.new {|r| r.locked?}

  validates :begin_date, :end_date, :presence=>true  
  validates :begin_date, :end_date, :within_period=>true
 

 # TODO voir si on remet ce after_create
 # after_create :fill_bank_extract_lines
  after_save :lock_lines_if_locked 

 
  # TODO add a chrono validator
  
  scope :period, lambda {|p| where('begin_date >= ? AND end_date <= ?' ,
      p.start_date, p.close_date).order(:begin_date) }
  scope :unlocked, where('locked = ?', false)

  # indique si l'extrait est le premier de ce compte bancaire qui doive être pointé
  def first_to_point?
    return false if locked?
    id == bank_account.first_bank_extract_to_point.id
  end

  def lockable?
    !self.locked? && self.equality?
  end
  
  def end_sold
    begin_sold+total_credit-total_debit
  end

  def total_lines_debit
    bank_extract_lines.all.sum(&:debit)
  end

  def total_lines_credit
    bank_extract_lines.all.sum(&:credit)
  end

  def diff_debit?
    diff_debit != 0
  end

  # Il est normal que l'on est débit d'un côté et crédit de l'autre
  # car on est d'un côté avec le relevé de compte envoyé par la banque
  # et donc du point de vue de la banque; et de l'autre côté du point de
  # vue de la structure.
  def diff_debit
    total_debit - total_lines_credit
  end

  def diff_credit?
    diff_credit != 0
  end

  def diff_credit
    total_credit - total_lines_debit
  end

  def equality?
    (self.diff_debit.abs < 0.001) && (self.diff_credit.abs < 0.001) 
  end

  def lines_sold
    total_lines_credit - total_lines_debit
  end

  def diff_sold
    begin_sold + lines_sold - end_sold
  end

  

  # retourne l'exercice correspondant à la date demandée, nil si pas trouvé
  def period
    bank_account.organism.find_period(begin_date) rescue nil
  end

  private

  # méthode appelée après la création d'un bank_extract
  # tente de pré remplir les lignes du relevé bancaire 
  # prend l'ensemble des lignes non pointées et 
  # crée des bank_extract_lines pour toutes les lignes dont les dates sont inférieures à la date de clôture

  # TODO mieux utiliser la requete sql
#  def fill_bank_extract_lines
#    npl=bank_account.np_lines
#    npl.reject! {|l| l.line_date > end_date}
#    npl.each {|l| BankExtractLine.create!(bank_extract_id: id, line_id: l.id)}
#    cdl=bank_account.np_check_deposits
#    cdl.reject! {|l| l.deposit_date > end_date}
#    cdl.each {|l| BankExtractLine.create!(bank_extract_id: id, check_deposit_id: l.id)}
#  end

  def lock_lines_if_locked
    bank_extract_lines.all.each {|bl| bl.lock_line} if locked
  end



end
