class AddColumnOwnerToLines < ActiveRecord::Migration
  def change
    add_column :lines, :owner_id, :integer

    add_column :lines, :owner_type, :string

  end
end
