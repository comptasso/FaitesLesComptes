class CheckDeposit < ActiveRecord::Base
  has_many :lines
  belongs_to :bank_account

  before_destroy :remove_check_deposit_id_in_lines

  private

  def remove_check_deposit_id_in_lines
    self.lines.each do |l|
      l.update_attribute(:check_deposit_id, nil)
      l.save
    end
  end
end
