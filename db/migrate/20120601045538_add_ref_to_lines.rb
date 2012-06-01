class AddRefToLines < ActiveRecord::Migration
  def change
    add_column :lines, :ref, :string

  end
end
