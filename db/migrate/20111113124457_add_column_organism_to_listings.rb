class AddColumnOrganismToListings < ActiveRecord::Migration
  def change
    add_column :listings, :organism_id, :integer
  end
end
