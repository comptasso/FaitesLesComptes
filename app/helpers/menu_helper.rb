# coding: utf-8

module MenuHelper

  def saisie_consult_organism_list
    rooms_with_period = current_user.rooms.select {|r| r.look_for { Organism.first.periods.any? } }
    lis = rooms_with_period.collect do |groom|
      content_tag :li ,link_to(groom.organism.title, room_path(groom))
    end
    lis.join('').html_safe
  end




  end
