# -*- encoding : utf-8 -*-

class Destination < ActiveRecord::Base
  belongs_to :organism
  has_many :lines
  validates :organism_id, :presence=>true
 default_scope order: 'name ASC'

  before_destroy :ensure_no_lines

  private

  def ensure_no_lines
    if lines.empty?
      return true
    else
      errors.add(:base, 'Des écritures font référence à cette destination')
      return false
    end
  end

end
