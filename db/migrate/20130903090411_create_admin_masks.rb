class CreateAdminMasks < ActiveRecord::Migration
  def change
    create_table :admin_masks do |t|
      t.string :title
      t.text :comment
      t.references :organism

      t.timestamps
    end
    add_index :admin_masks, :organism_id
  end
end
