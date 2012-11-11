class ChangeColumnTypeCommentToCashes < ActiveRecord::Migration
  def up
    remove_column :cashes, :comment, :string
    add_column :cashes, :comment, :text
  end

  def down
    remove_column :cashes, :comment, :text 
    add_column :cashes, :comment, :string
    
  end
end
