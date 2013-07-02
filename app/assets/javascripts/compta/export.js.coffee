# fichier ayant pour objet de bloquer la page et d'afficher un message juste un instant
# lorsqu'on clique sur une des trois icones d'export

$ ->
  mytoken = 0
  finish_export = ->
    window.clearInterval(fileDownloadCheckTimer)
    $.removeCookie('export_token', { path: '/' })
    $.unblockUI()

  $('#icon_pdf').click ->
    mytoken = new Date().getTime().toString() #use the current timestamp as the token value
    lien = $('#icon_pdf').attr('href')
    $('#icon_pdf').attr('href', "#{lien}&token=#{mytoken}")
    block_page()

  $('#icon_csv').click ->
    mytoken = new Date().getTime().toString() #use the current timestamp as the token value
    lien = $('#icon_csv').attr('href')
    $('#icon_csv').attr('href', "#{lien}&token=#{mytoken}")
    block_page()

  $('#icon_xls').click ->
    mytoken = new Date().getTime().toString() #use the current timestamp as the token value
    lien = $('#icon_xls').attr('href')
    $('#icon_xls').attr('href', "#{lien}&token=#{mytoken}")
    block_page()

  block_page = ->
    $.blockUI({ message: '<h1><img src="/assets/loading.gif" /> Juste un instant...</h1>' })
    fileDownloadCheckTimer = window.setInterval( ->
        cookieValue = $.cookie('export_token')
        finish_export() if cookieValue is mytoken
      ,1000)
