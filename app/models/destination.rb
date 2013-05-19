# -*- encoding : utf-8 -*-

class Destination < ActiveRecord::Base

  attr_accessible :name, :comment, :income_outcome

  belongs_to :organism
  has_many :compta_lines

  validates :organism_id, :presence=>true
  validates :name, presence: true, uniqueness:true, :format=>{with:NAME_REGEX}, :length=>{:within=>NAME_LENGTH_LIMITS}
  validates :comment, :format=>{with:NAME_REGEX}, :length=>{:maximum=>MAX_COMMENT_LENGTH}, :allow_blank=>true
  validates :income_outcome, :inclusion=>{:in=>[true, false]}

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
