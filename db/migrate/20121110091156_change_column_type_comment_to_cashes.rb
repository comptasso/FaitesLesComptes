class ChangeColumnTypeCommentToCashes < ActiveRecord::Migration
  def up
    remove_column :cashes, :comment
    add_column :cashes, :comment, :text
  end

  def down
    remove_column :cashes, :comment 
    add_column :cashes, :comment, :string
    
  end
end
