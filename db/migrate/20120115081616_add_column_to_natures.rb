class AddColumnToNatures < ActiveRecord::Migration
 
  class Nature < ActiveRecord::Base
  end
  # migration qui change la logique de nature pour le rattacher à period, plutôt qu'a organisme
  def up
     add_column :natures, :period_id, :integer # on ajoute une colonne period_id
    # pour toutes les périodes relevant de organisme, on remplit period_id

#    Nature.reset_column_information
#    Nature.all.each do |n|
#       n.organism.periods.first { |p|  n.update_attributes! :period_id=>p.id } if n.organism.periods.count > 0
#    end
#
#    # on peut enlever la colonne organism_id
#    remove_column :natures, :organism_id
#    add_column :natures, :account_id, :integer # on ajout la colonne account_id
#    drop_table :accounts_natures # on supprime la table habtm

  end

  def down
   remove_column :natures, :period_id
  end
end
