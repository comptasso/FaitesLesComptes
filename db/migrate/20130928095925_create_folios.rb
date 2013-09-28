class CreateFolios < ActiveRecord::Migration
  def change
    create_table :folios do |t|
      t.string :name
      t.string :title
      t.string :sens
      t.references :nomenclature

      t.timestamps
    end
  end
end
