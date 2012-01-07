class AddColumnIncomeToDestination < ActiveRecord::Migration
  def change
    add_column :destinations, :income_outcome, :boolean, :default=>false
  end
end
