class AddFieldsToMask < ActiveRecord::Migration
  def change
    add_column :masks, :book_id, :integer
    add_column :masks, :nature_name, :string
    add_column :masks, :narration, :string
    add_column :masks, :destination_id, :integer
    add_column :masks, :mode, :string
    add_column :masks, :counterpart, :string
    add_column :masks, :ref, :string
    add_column :masks, :amount, :decimal
  end
end
