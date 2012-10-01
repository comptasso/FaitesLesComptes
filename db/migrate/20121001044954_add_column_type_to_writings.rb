class AddColumnTypeToWritings < ActiveRecord::Migration
  def change
    add_column :writings, :type, :string

  end
end
