# pour chaque élément case à cocher dans la table des accounts relevant
# de la classe acc_used, on attache un évènement on_change
$ ->
  $('.admin_accounts').on 'click', '.acc_used input', (e)->
    accid = $(this)
    $.ajax 
      # récupérer l'id de la account (value)
      url: window.location.pathname + '/' + accid.attr('value') + '/toggle_used'
      type: 'put'
#      success: (data, textStatus, jqXHR) ->
#        destid.parent('tr').effect('highlight', {}, 1500)
      error: (jqXHR, textStatus, errorThrown) ->
        accid.parent('td').effect('highlight', {}, 1500)
