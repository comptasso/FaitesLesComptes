# Cette migration a pour but de permettre qu'un schéma (une Room) soit
# accessible à plusieurs personnes, l'une en tant que 'owner', les autres en
# tant que 'guest'.
#
# Pour cette migration, il n'y a encore que des owners
#
class CreateHolders < ActiveRecord::Migration
  def up

    create_table :holders do |t|
      t.integer :user_id
      t.integer :room_id
      t.string :status

      t.timestamps
    end

    Holder.reset_column_information
      # ici on remplit la table holder avec les rooms existant
      Room.find_each do |r|
        h = Holder.new
        h.user_id = r.user_id
        h.room_id = r.id
        h.status = 'owner'
        h.save
    end

    remove_column :rooms, :user_id

  end


  def down

   add_column :rooms, :user_id, :integer

    Room.reset_column_information

      Holder.find_each do |h|
        if h.status == 'owner'
          r = Room.find(h.room_id)
          r.user_id = h.user_id
          r.save
        end
      end

    drop_table :holders
  end
end
