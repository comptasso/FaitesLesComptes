class BankExtract < ActiveRecord::Base
  belongs_to :bank_account
  has_many :bank_extract_lines

  validates :begin_sold, :total_debit, :total_credit, :numericality=>true

  after_create :fill_bank_extract_lines


#  def fill_bank_extract_lines
#    # TRAITEMENT DES LIGNES
#    # on recherche toutes les lignes qui ne sont pas déja rattachées à un relevé de compte
#    Line.where('check_deposit_id IS NULL').where('lines.')
#    # et qui ne relèvent pas non plus d'une remise de chèques
#    # on associe toutes celles dont la date est antérieure à la clôture
#
#    # TRAITEMENT DES REMISES DE CHEQUES
#    # on regarde toutes celles antérieures à la date de fin du relevé
#    # et on les associe
#  end

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
    (self.diff_debit.abs < 0.001) && (self.diff_credit < 0.001)
  end

  def lines_sold
    self.total_lines_credit - self.total_lines_debit
  end

  def diff_sold
    self.begin_sold + self.lines_sold - self.end_sold
  end

  private

  def fill_bank_extract_lines
    # TODO fill_bank_extract_lines
  end
end
