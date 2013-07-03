# Bloque la page et affiche le message juste un moment lorsqu'on clique sur le lien journal général du menu editions

$ ->
  finish_general_ledger = ->
    window.clearInterval(fileDownloadCheckTimer)
    $.removeCookie('general_ledger_token', { path: '/' })
    $.unblockUI()

  $('#nav_general_ledger').click ->
    mytoken = new Date().getTime().toString(); #use the current timestamp as the token value
    lien = $('#nav_general_ledger').attr('href');
    lien = lien + '?token=' + mytoken;  # on ajoute le token au paramètre
    $('#nav_general_ledger').attr('href', lien);
    $.blockUI({ message: '<h1><img src="/assets/loading.gif" /> Juste un moment...</h1>' });

    fileDownloadCheckTimer = window.setInterval( ->
        cookieValue = $.cookie('general_ledger_token')
        finish_general_ledger() if cookieValue is mytoken
      ,1000);





