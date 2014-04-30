class AddComptaToImportedBels < ActiveRecord::Migration
  def change
    add_column :imported_bels, :cat, :string
    add_column :imported_bels, :nature_id, :integer
    add_column :imported_bels, :payment_mode, :string
    add_column :imported_bels, :destination_id, :integer
    add_column :imported_bels, :ref, :string
  end
end
