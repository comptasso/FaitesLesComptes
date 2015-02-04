# pour chaque élément case à cocher dans la table des destinations relevant
# de la classe dest_used, on attache un évènement on_change
$ ->
  $('.admin_destinations').on 'click', '.dest_used input', (e)->
    destid = $(this)
    $.ajax 
      # récupérer l'id de la destination (value)
      url: window.location.pathname + '/' + destid.attr('value') + '/toggle_used'
      type: 'post'
      success: (data, textStatus, jqXHR) ->
        destid.parent('td').effect('highlight', {}, 1500)
      error: (jqXHR, textStatus, errorThrown) ->
        destid.parent('td').effect('highlight', {}, 1500)
