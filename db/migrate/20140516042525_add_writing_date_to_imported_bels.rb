class AddWritingDateToImportedBels < ActiveRecord::Migration
  def change
    add_column :imported_bels, :writing_date, :date
  end
end
