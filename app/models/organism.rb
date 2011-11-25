class Organism < ActiveRecord::Base
  has_many :listings, dependent: :destroy
  has_many :destinations, dependent: :destroy
  has_many :natures, dependent: :destroy
  
end
