class AddColumnIncomeToNature < ActiveRecord::Migration
  def change
    add_column :natures, :income_outcome, :boolean, :default=>false
  end
end
