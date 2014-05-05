class AddComptaLineIdToImportedBels < ActiveRecord::Migration
  def change
    add_column :imported_bels, :writing_id, :integer
  end
end
