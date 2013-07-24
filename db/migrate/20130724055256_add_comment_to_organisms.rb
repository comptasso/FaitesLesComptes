class AddCommentToOrganisms < ActiveRecord::Migration
  def change
    add_column :organisms, :comment, :string
  end
end
