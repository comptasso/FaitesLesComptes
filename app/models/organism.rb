class Organism < ActiveRecord::Base
  has_many :listings
  has_many :destinations
  has_many :natures
end
