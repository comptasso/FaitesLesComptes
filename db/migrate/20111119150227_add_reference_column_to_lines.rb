class AddReferenceColumnToLines < ActiveRecord::Migration
  def change
    add_column :lines, :copied_id, :string
    add_column :lines, :multiple, :boolean, default: false
    
  end
end
