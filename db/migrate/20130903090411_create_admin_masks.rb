class CreateAdminMasks < ActiveRecord::Migration
  def change
    create_table :masks do |t|
      t.string :title
      t.text :comment
      t.references :organism

      t.timestamps
    end
    add_index :masks, :organism_id
  end
end
