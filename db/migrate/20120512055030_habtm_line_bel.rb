class HabtmLineBel < ActiveRecord::Migration
  def up
    create_table :bank_extract_lines_lines, :id=>false do |t|
      t.references :bank_extract_line
      t.references :line
    end

    # ajout d'une colonne type dans bank_extract_lines pour en faire une STI
    add_column :bank_extract_lines, :type, :string
  end

  def down
    drop_table :bank_extract_lines_lines
    remove_column :bank_extract_lines, :type
  end
end
