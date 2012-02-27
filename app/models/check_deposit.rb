# coding: utf-8

class CheckDeposit < ActiveRecord::Base
  has_many :lines, dependent: :nullify
  belongs_to :bank_account
  has_one :bank_extract_line

  attr_reader :total

  validates :bank_account, :presence=>true

  before_validation :not_empty

  after_initialize :set_total
  # list_lines ne doit pas être vide
 
  # FIXME : le problème ici est que total ne fonctionne pas pour les nouveaux enregistrements
  # car l'id est null et rails fait la somme des enregistrements qui ont check_depositçid == null
  # après une première sauvegarde, les montants sont corrects

  def self.total_to_pick(organism)
    organism.lines.non_depose.sum(:credit)
  end

  def self.nb_to_pick(organism)
    organism.lines.non_depose.count
  end


  def self.lines_to_pick(organism)
    organism.lines.non_depose
  end

  def remove_check(line)
    lines.delete(line)
     @total -= line.credit
  end

  
  def pick_check(line)
    lines <<  line
    @total += line.credit 
  end

  def pick_all_checks
    lines << self.bank_account.organism.lines.non_depose.all
    @total += self.bank_account.organism.lines.non_depose.sum(:credit) if new_record?
  end

  private

  def not_empty
    if lines.empty?
      self.errors[:base] <<  'Il doit y avoir au moins un chèque dans une remise'
    end
  end

  def set_total
    @total = new_record? ? 0 : lines.sum(:credit)
  end

  
end
