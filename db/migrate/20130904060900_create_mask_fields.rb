class CreateMaskFields < ActiveRecord::Migration
  def change
    create_table :mask_fields do |t|
      t.references :mask
      t.string :label
      t.string :content

      t.timestamps
    end
    add_index :mask_fields, :mask_id
  end
end
