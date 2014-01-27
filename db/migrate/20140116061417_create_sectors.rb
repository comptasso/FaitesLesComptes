class CreateSectors < ActiveRecord::Migration
  def up
    create_table :sectors do |t|
      t.integer :organism_id
      t.string :name

      t.timestamps
    end
    
    add_column :books, :sector_id, :integer
    Book.reset_column_information
    
    # ici il faut créer un secteur puis rattacher les livres à ce sector
    if o = Organism.first
      s = Sector.create!(organism_id:o.id, name:'Global')
      o.in_out_books.each {|b| b.update_attribute(:sector_id, s.id)}   
    end
    
    
  end
  
  def down
    
    remove_column :books, :sector_id
    
    drop_table :sectors
    
  end
  
end
