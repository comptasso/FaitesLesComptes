# l'objectif est de remettre à jour par un appel ajax, la vue natures
# lorsqu'on change de destinations 
$ ->
  $('form select#destination').on 'change', ->
#    accid = $(this)
     $.ajax 
#      # récupérer l'id de la account (value)
       url: window.location.pathname + '.js?destination=' + $('select option:selected').index()
#       type: 'get'
       success: (data, textStatus, jqXHR) ->
         $('#analyse_natures').effect('highlight', {}, 1500)
#      error: (jqXHR, textStatus, errorThrown) ->
#        accid.parent('td').effect('highlight', {}, 1500)
