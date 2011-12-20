class CheckDeposit < ActiveRecord::Base
  has_many :lines
  belongs_to :bank_account
  has_one :bank_extract_line

  before_destroy :remove_check_deposit_id_in_lines

  def total
    self.lines.sum(&:credit)
  end

  private

  def remove_check_deposit_id_in_lines
    self.lines.each do |l|
      l.update_attribute(:check_deposit_id, nil)
      l.save
    end
  end
end
