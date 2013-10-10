# méthode pour construire une url en rajoutant un token
fnAddToken= (url, token) ->
  if /.*\?.*/.test(url) # l'url contient déja un ? et donc des paramètres
    "#{url}&token=#{token}" # on ajoute notre paramètre
  else
    "#{url}?token=#{token}" # il n'y a que ce paramètre
  


# fichier ayant pour objet de bloquer la page et d'afficher un message juste un instant
# lorsqu'on clique sur une des trois icones d'export
#
$ ->
  $.removeCookie('export_token', { path: '/' }) # au cas où un précédent serait resté
  mytoken = 0
  # TODO utiliser une boucle plutôt que se répéter
  # il faudrait aussi remettre le lien en état plutot qu'ajouter des token les uns à la suite des autres si on
  finish_export = ->
    window.clearInterval(fileDownloadCheckTimer)
    $.removeCookie('export_token', { path: '/' })
    $.unblockUI()

  $('#icon_pdf').click ->
    mytoken = new Date().getTime().toString() #use the current timestamp as the token value
    lien = $('#icon_pdf').attr('href')
    $('#icon_pdf').attr('href', fnAddToken(lien, mytoken))
    block_page()

  $('#icon_csv').click ->
    mytoken = new Date().getTime().toString() #use the current timestamp as the token value
    lien = $('#icon_csv').attr('href')
    $('#icon_csv').attr('href', fnAddToken(lien, mytoken))
    block_page()

  $('#icon_xls').click ->
    mytoken = new Date().getTime().toString() #use the current timestamp as the token value
    lien = $('#icon_xls').attr('href')
    $('#icon_xls').attr('href', fnAddToken(lien, mytoken))
    block_page()
    

  block_page = ->
    $.blockUI({ message: '<h1>Juste un instant...</h1>' })
    fileDownloadCheckTimer = window.setInterval( ->
        cookieValue = $.cookie('export_token')
        finish_export() if cookieValue is mytoken
      ,1000)
