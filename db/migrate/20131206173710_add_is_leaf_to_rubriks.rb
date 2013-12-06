class AddIsLeafToRubriks < ActiveRecord::Migration
  def up
    add_column :rubriks, :is_leaf, :boolean, :default=>false
    
    Rubrik.all.each {|r| r.update_attribute(:is_leaf, true) if r.leaf?}
    
  end
  
  def down
    remove_column :rubriks, :is_leaf
  end
end
