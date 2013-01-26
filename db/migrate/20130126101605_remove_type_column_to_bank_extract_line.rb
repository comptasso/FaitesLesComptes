class RemoveTypeColumnToBankExtractLine < ActiveRecord::Migration
  def up
    remove_column :bank_extract_lines, :type
  end

  def down
    add_column :bank_extract_lines, :type, :string
  end
end
