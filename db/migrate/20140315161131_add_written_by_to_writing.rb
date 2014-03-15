class AddWrittenByToWriting < ActiveRecord::Migration
  def change
    add_column :writings, :written_by, :integer
    add_column :writings, :user_ip, :string
    add_column :check_deposits, :written_by, :integer
    add_column :check_deposits, :user_ip, :string
  end
end
