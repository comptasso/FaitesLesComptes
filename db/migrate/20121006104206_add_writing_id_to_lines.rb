class AddWritingIdToLines < ActiveRecord::Migration
  def change
    add_column :lines, :writing_id, :integer

  end
end
