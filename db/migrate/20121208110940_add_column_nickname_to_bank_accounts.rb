class AddColumnNicknameToBankAccounts < ActiveRecord::Migration
  def up
    add_column :bank_accounts, :nickname, :string
    remove_column :bank_accounts, :address

    BankAccount.all.each {|ba| ba.update_attribute(:nickname, ba.to_s)}
  end

  def down
    remove_column :bank_accounts, :nickname
    add_column :bank_accounts, :address, :string 
  end
end
