class RemoveColumnBankExtractIdFromComptaLines < ActiveRecord::Migration
  def up
    remove_column :compta_lines, :bank_extract_id
    add_column :organisms, :version, :string
  end

  def down
    add_column :compta_lines, :bank_extract_id, :integer
    remove_column :organisms, :version
  end
end
