class ReformatTableLines < ActiveRecord::Migration
  def up
    remove_column :lines, :line_date
    remove_column :lines, :ref
    remove_column :lines, :narration
    remove_column :lines, :owner_id
    remove_column :lines, :owner_type
    remove_column :lines, :counter_account_id
    remove_column :lines, :book_id

    rename_table :lines, :compta_lines 

  end

  def down
    add_column :lines, :line_date, :date
    add_column :lines, :ref, :string
    add_column :lines, :narration, :string
    add_column :lines, :owner_id, :integer
    add_column :lines, :owner_type, :string
    add_column :lines, :counter_account_id, :integer
    add_column :lines, :book_id, :integer

    rename_table :compta_lines, :lines
  end
end
