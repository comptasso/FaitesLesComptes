class AddWrittenByToWriting < ActiveRecord::Migration
  def change
    add_column :writings, :written_by, :numeric
    add_column :writings, :user_ip, :string
  end
end
