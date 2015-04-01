class AddFieldsToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :siren, :string
    add_column :organisms, :postcode, :string
  end
end
