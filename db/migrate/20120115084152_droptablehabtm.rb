class Droptablehabtm < ActiveRecord::Migration
  def up
    remove_column :natures, :organism_id
    add_column :natures, :account_id, :integer # on ajout la colonne account_id
    drop_table :accounts_natures # on supprime la table habtm

  end

  def down
    raise IrreversibleMigration
  end
end
