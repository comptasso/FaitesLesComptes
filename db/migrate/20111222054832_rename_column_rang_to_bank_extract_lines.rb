class RenameColumnRangToBankExtractLines < ActiveRecord::Migration
  def down
    rename_column :bank_extract_lines, :position, :rang
  end

  def up
    rename_column :bank_extract_lines, :rang, :position
  end
end
