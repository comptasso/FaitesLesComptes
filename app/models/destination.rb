# -*- encoding : utf-8 -*-

class Destination < ActiveRecord::Base 
  belongs_to :organism
  has_many :compta_lines
  validates :organism_id, :presence=>true
  validates :name, :presence=>true, uniqueness:true
  default_scope order: 'name ASC'

  before_destroy :ensure_no_lines

  private

  def ensure_no_lines
    if compta_lines.empty?
      return true
    else
      errors.add(:base, 'Des écritures font référence à cette destination')
      return false
    end
  end

end
