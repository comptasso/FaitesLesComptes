# -*- encoding : utf-8 -*-
class Nature < ActiveRecord::Base
 
  belongs_to :organism

  validates :organism_id, :presence=>true
  
   has_many :lines
   default_scope order: 'name ASC'

  before_destroy :ensure_no_lines

  private

  def ensure_no_lines
    if lines.empty?
      return true
    else
      errors.add(:base, 'Des écritures font référence à cette nature')
      return false
    end
  end

end
