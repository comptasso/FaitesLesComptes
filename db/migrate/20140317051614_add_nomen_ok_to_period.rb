class AddNomenOkToPeriod < ActiveRecord::Migration
  def change
    add_column :periods, :nomenclature_ok, :boolean, default:false
  end
end
