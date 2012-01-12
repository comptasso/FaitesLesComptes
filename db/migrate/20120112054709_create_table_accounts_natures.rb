class CreateTableAccountsNatures < ActiveRecord::Migration
  def change
    create_table :accounts_natures, :id=>false  do |t|
      t.integer :account_id
      t.integer :nature_id
      t.timestamps
    end
  end
end
