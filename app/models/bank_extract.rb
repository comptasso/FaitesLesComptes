# -*- encoding : utf-8 -*-

class BankExtract < ActiveRecord::Base
  belongs_to :bank_account
  has_many :bank_extract_lines, dependent: :destroy

  validates :begin_sold, :total_debit, :total_credit, :numericality=>true

  after_create :fill_bank_extract_lines
  after_save :lock_lines_if_locked


  
  scope :period, lambda {|p| where('(begin_date <= ? AND end_date >= ?)  OR (begin_date <= ? AND end_date >= ? ) OR (begin_date  >= ? AND end_date  <= ?)',
      p.start_date, p.start_date, p.close_date, p.close_date, p.start_date, p.close_date).order(:begin_date) }

  def self.find_by_month_and_year(m,y)
    m = m.to_i ; y = y=y.to_i
    debut=Date.civil(y,m,1)
    fin=debut.end_of_month
    BankExtract.order('end_date ASC').where(['end_date >= ? and end_date <= ?', debut, fin]).last
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

  def diff_debit
    self.total_debit - self.total_lines_debit
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
