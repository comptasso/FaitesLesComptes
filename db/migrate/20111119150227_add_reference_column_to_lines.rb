class AddReferenceColumnToLines < ActiveRecord::Migration
  def change
    add_column :lines, :reference, :string
  end
end
