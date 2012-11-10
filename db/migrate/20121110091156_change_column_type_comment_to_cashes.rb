class ChangeColumnTypeCommentToCashes < ActiveRecord::Migration
  def up
    remove_column :cashes, :comment, :string
    add_column :cashes, :comment, :text
  end

  def down
    add_column :cashes, :comment, :string
    remove_column :cashes, :comment, :text 
  end
end
