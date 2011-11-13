class CreateNatures < ActiveRecord::Migration
  def change
    create_table :natures do |t|
      t.string :name
      t.integer :organism_id
      t.text :comment

      t.timestamps
    end
  end
end
