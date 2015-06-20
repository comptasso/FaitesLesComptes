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

# gestion de l'affichage de la table des comptes par dataTable
$ ->
  table_account = [{"sType": "string"}, null, null, null, {"bSortable": false}]
  # Dans le cas des tables sectorisées, on a une colonne supplémentaire
  if $('.admin_accounts .dataTable thead').attr('class') == 'sectored'
    col_types = [{"sType": "string"}].concat(table_account)
  else 
    col_types = table_account;
  
  $('.admin_accounts .dataTable').dataTable(        
    "aoColumns": col_types,
    "iDisplayLength": 10,
    "aLengthMenu": [[10, 25, 50, -1], [10, 25, 50, "Tous"]]
    )
        
    