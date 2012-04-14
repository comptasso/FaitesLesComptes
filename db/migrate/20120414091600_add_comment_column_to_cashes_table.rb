class AddCommentColumnToCashesTable < ActiveRecord::Migration
  def change
    add_column :cashes, :comment, :string
  end
end
