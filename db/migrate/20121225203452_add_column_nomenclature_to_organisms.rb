class AddColumnNomenclatureToOrganisms < ActiveRecord::Migration
  def change
    add_column :organisms, :nomenclature, :text
  end
end
