class CreateDestinations < ActiveRecord::Migration
  def change
    create_table :destinations do |t|
      t.string :name
      t.integer :organism_id
      t.text :comment

      t.timestamps
    end
  end
end
