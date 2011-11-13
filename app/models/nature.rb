class Nature < ActiveRecord::Base
 
  belongs_to :organism

  validates :organism_id, :presence=>true
  
   has_many :lines

end
