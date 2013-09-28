class CreateRubriks < ActiveRecord::Migration
  def change
    create_table :rubriks do |t|
      t.string :name
      t.string :numeros
      t.integer :parent_id
      t.references :folio

      t.timestamps
    end
  end
end
