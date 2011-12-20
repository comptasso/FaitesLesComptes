class CreateBankExtractLines < ActiveRecord::Migration
  def change
    create_table :bank_extract_lines do |t|
      t.integer :rang
      t.integer :bank_extract_id
      t.integer :line_id
      t.integer :bank_extract_id
      t.timestamps
    end

    rename_column :bank_extracts,:bank_account_id, :book_id
  end
end
