class AddColumnPointedToBankExtracts < ActiveRecord::Migration
  def change
    add_column :bank_extracts, :pointed, :boolean, :default=>false
  end
end
