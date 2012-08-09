class User < ActiveRecord::Base
  has_many :rooms

  attr_reader :active_organism

  # TODO avoir ici un active_organism qui a du sens
  def enter_first_room
    @active_organism = Organism.first
    #ooms.first.database_name
  end
end
