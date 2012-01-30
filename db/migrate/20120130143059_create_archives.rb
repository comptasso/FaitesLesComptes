class CreateArchives < ActiveRecord::Migration
  def change
    create_table :archives do |t|
      t.integer :organism_id, null: false
      t.string :comment

      t.timestamps
    end
  end
end
