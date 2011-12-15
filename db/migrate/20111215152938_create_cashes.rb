class CreateCashes < ActiveRecord::Migration
  def change
    create_table :cashes do |t|
      t.integer :organism_id
      t.string :name

      t.timestamps
    end
  end
end
