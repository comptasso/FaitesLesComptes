class ChangeTableNameListingToBook < ActiveRecord::Migration
  def change
    rename_table 'listings','books'

    rename_column :bank_extracts, :listing_id, :book_id
    rename_column :lines, :listing_id, :book_id

  end

  
end
