class CreateAdherentBridges < ActiveRecord::Migration
  def change
    create_table :adherent_bridges do |t|
      t.integer :organism_id
      t.integer :bank_account_id
      t.integer :cash_id
      t.integer :destination_id
      t.string :nature_name
      t.integer :income_book_id

      t.timestamps
    end
  end
end
