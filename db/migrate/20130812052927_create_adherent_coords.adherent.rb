# This migration comes from adherent (originally 20130805152911)
class CreateAdherentCoords < ActiveRecord::Migration
  def change
    create_table :adherent_coords do |t|
      t.string :mail
      t.string :tel
      t.string :gsm
      t.string :office
      t.text :address
      t.string :zip
      t.string :city
      t.references :member

      t.timestamps
    end
  end
end
