# Mise en place d'une action ajax qui lance l'édition pdf du journal général
$ ->
  $('#generalajax').click ->
    path = "/compta/periods/#{$(this).data("period")}/general_ledger/produce_pdf"
    $.ajax
      url: path,
      type: 'get'
