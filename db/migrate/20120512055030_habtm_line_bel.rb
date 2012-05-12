class HabtmLineBel < ActiveRecord::Migration
  def up
    create_table :bank_extract_lines_lines, :id=>false do |t|
      t.references :bank_extract_line
      t.references :line
    end
    # on retire la colonne id
    remove_column :bank_extract_lines, :line_id
    

    # ajout d'une colonne type dans bank_extract_lines pour en faire une STI
    add_column :bank_extract_lines, :type, :string
    add_column :bank_extract_lines, :date, :date
  end

  def down
    remove_column :bank_extract_lines, :date
    remove_column :bank_extract_lines, :type

    add_column :bank_extract_lines, :line_id, :integer
    drop_table :bank_extract_lines_lines
    
  end
end
