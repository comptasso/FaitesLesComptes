class AddColumnNomenclatureToOrganisms < ActiveRecord::Migration
  def up
    create_table :nomenclatures do |t|
      t.integer :organism_id
      t.text :actif
      t.text :passif
      t.text :resultat
      t.text :benevolat

      t.timestamps

      

    end

    # on crée la nomenclature pour l'organisme de cette base
      Organism.first.send(:fill_nomenclature) if Organism.any?

    
  end


  def down
    drop_table :nomenclatures
  end

end
