class AddConfirmToUser < ActiveRecord::Migration
  def change
    add_column :users, :skip_confirm_change_password, :boolean, default:false
  end
end
