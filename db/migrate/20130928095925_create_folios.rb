class CreateFolios < ActiveRecord::Migration
  def up
    create_table :folios do |t|
      t.string :name
      t.string :title
      t.string :sens
      t.references :nomenclature

      t.timestamps
    end
    
    remove_column :nomenclatures, :actif
    remove_column :nomenclatures, :passif
    remove_column :nomenclatures, :resultat
    remove_column :nomenclatures, :benevolat
  end
  
  def down
    drop_table :folios
    
    add_column :nomenclatures, :actif, :text
    add_column :nomenclatures, :passif, :text
    add_column :nomenclatures, :resultat, :text
    add_column :nomenclatures, :benevolat, :text
  end
end
