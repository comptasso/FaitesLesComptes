class AddRefToLines < ActiveRecord::Migration
  def change
    add_column :lines, :ref, :string
    add_column :lines, :check_number, :string

  end
end
