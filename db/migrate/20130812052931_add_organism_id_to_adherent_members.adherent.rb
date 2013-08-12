# This migration comes from adherent (originally 20130810073908)
class AddOrganismIdToAdherentMembers < ActiveRecord::Migration
  def change
    add_column :adherent_members, :organism_id, :integer
  end
end
