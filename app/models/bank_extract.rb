# -*- encoding : utf-8 -*-

class BankExtract < ActiveRecord::Base
  include Utilities::PickDateExtension
  
  belongs_to :bank_account
  has_many :bank_extract_lines, dependent: :destroy
  has_many :standard_bank_extract_lines, dependent: :destroy
  has_many :check_deposit_bank_extract_lines, dependent: :destroy 
  # has_many :check_deposits, :through=>:check_deposit_bank_extract_lines


  validates :begin_sold, :total_debit, :total_credit, :numericality=>true
  validates :begin_sold, :total_debit, :total_credit, :presence=>true
   # validates :check_deposits, uniqueness: true
  
 # after_create :fill_bank_extract_lines
  after_save :lock_lines_if_locked

 
  # TODO add a chrono validator
  
  scope :period, lambda {|p| where('(begin_date <= ? AND end_date >= ?)  OR (begin_date <= ? AND end_date >= ? ) OR (begin_date  >= ? AND end_date  <= ?)',
      p.start_date, p.start_date, p.close_date, p.close_date, p.start_date, p.close_date).order(:begin_date) }

  # utilise le module Utilities::PickDateExtension pour créer des virtual attributes 
  # begin_date_picker et end_date_picker
  pick_date_for :begin_date, :end_date
 
  # on cherche le relevé de compte qui soit dans le mois de date, mais le plus proche de la
  # fin du mois
  def self.find_nearest(date)
    debut=date.beginning_of_month
    fin=debut.end_of_month
    BankExtract.order('end_date ASC').where(['end_date >= ? and end_date <= ?', debut, fin]).last
  end

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
    self.bank_extract_lines.all.sum(&:debit)
  end

  def total_lines_credit
    self.bank_extract_lines.all.sum(&:credit)
  end

  def diff_debit?
    self.total_debit != self.total_lines_debit
  end

  def diff_debit
    self.total_debit - self.total_lines_debit
  end

  def diff_credit?
    self.total_credit != self.total_lines_credit
  end

  def diff_credit
    self.total_credit - self.total_lines_credit
  end

  def equality?
    (self.diff_debit.abs < 0.001) && (self.diff_credit.abs < 0.001) 
  end

  def lines_sold
    self.total_lines_credit - self.total_lines_debit
  end

  def diff_sold
    self.begin_sold + self.lines_sold - self.end_sold
  end

  def status
    self.locked? ? 'Verrouillé' : 'Non Verrouillé'
  end

  private

  # méthode appelée après la création d'un bank_extract
  # tente de pré remplir les lignes du relevé bancaire 
  # prend l'ensemble des lignes non pointées et 
  # crée des bank_extract_lines pour toutes les lignes dont les dates sont inférieures à la date de clôture

  # TODO mieux utiliser la requete sql
  def fill_bank_extract_lines
    npl=bank_account.np_lines
    npl.reject! {|l| l.line_date > end_date}
    npl.each {|l| BankExtractLine.create!(bank_extract_id: id, line_id: l.id)}
    cdl=bank_account.np_check_deposits
    cdl.reject! {|l| l.deposit_date > end_date}
    cdl.each {|l| BankExtractLine.create!(bank_extract_id: id, check_deposit_id: l.id)}
  end

  def lock_lines_if_locked
    if self.locked
      self.bank_extract_lines.all.each {|bl| bl.lock_line}
    end
  end



end
