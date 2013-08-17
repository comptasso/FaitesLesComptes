# -*- encoding : utf-8 -*-

require 'strip_arguments'

# La classe Destination permet d'avoir un axe d'analyse pour les données de la 
# comptabilité.
# 
# Il n'y a pas d'obligation d'avoir une ou des destinations. Les destinations 
# enregistrent les dépenses comme les recettes et donc permettent d'avoir des
# résultats économiques par destinations.
# 
# TODO : supprimer le champ income_outcome inutilisé (à vérifier)
#
class Destination < ActiveRecord::Base

  attr_accessible :name, :comment, :income_outcome

  belongs_to :organism
  has_many :compta_lines

  strip_before_validation :name, :comment

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
