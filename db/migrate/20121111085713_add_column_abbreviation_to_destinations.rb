class AddColumnAbbreviationToDestinations < ActiveRecord::Migration
  def up
    add_column :books, :abbreviation, :string
    Book.find_each {|b| b.update_attribute(:abbreviation, b.title)}
  end


  def down
    remove_column :books, :abbreviation
  end
end
