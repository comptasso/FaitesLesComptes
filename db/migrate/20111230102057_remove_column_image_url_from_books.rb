class RemoveColumnImageUrlFromBooks < ActiveRecord::Migration
  def up
    remove_column :books, :image_url
  end

  def down
    add_column :books, :image_url, :string
  end
end
