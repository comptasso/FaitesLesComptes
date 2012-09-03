class AddCounterAccountIdToLines < ActiveRecord::Migration
  def change
    add_column :lines, :counter_account_id, :integer

  end
end
