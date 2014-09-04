# coding: utf-8

module Admin::OrganismsHelper

 
  # indique si le current_user est le propriétaire de l'organisme
  def owner?(organism)
    rid = Room.find_by_database_name(organism.database_name)
    current_user.holders.where('status = ? AND room_id = ?', 'owner', rid).any?
  end
  
  # destiné à indiquer dans la vue show quand a été faite la dernière 
  # construction des valeurs des différentes rubriques utilisées dans 
  # les folios. 
  # 
  # Indique jamais si ce n'a pas encore été fait
  def last_data_build(organism)
    nomen = organism.nomenclature
    return 'jamais' unless nomen.job_finished_at
    return 'il y a ' + time_ago_in_words(nomen.job_finished_at,
      include_seconds:true)
  end


end