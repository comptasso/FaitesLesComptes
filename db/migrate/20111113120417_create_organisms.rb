class CreateOrganisms < ActiveRecord::Migration
  def change
    create_table :organisms do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
