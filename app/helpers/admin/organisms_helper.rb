# coding: utf-8

module Admin::OrganismsHelper

include Admin::MenusHelper
  # indique si le current_user est le propriétaire de l'organisme
  def owner?(organism)
    current_user.holders.where('status = ? AND organism_id = ?',
         'owner', @organism.id).any?
  end

  # destiné à indiquer dans la vue show quand a été faite la dernière
  # construction des valeurs des différentes rubriques utilisées dans
  # les folios.
  #
  # Indique jamais si ce n'a pas encore été fait
  def last_data_build(organism)
    nomen = organism.nomenclature
    return 'pas encore' unless nomen.job_finished_at
    return 'il y a ' + time_ago_in_words(nomen.job_finished_at,
      include_seconds:true)
  end


end
