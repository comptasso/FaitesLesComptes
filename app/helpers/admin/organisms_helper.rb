# coding: utf-8

module Admin::OrganismsHelper

 
  # indique si le current_user est le propriétaire de l'organisme
  def owner?(organism)
    rid = Room.find_by_database_name(organism.database_name)
    current_user.holders.where('status = ? AND room_id = ?', 'owner', rid).any?
  end
  
 


end