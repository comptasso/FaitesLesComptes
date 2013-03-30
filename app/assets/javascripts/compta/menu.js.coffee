# Affiche le spinner quand on clique sur le bouton journal général du menu
$ ->
  $('#nav_general_ledger').click ->
    target = document.getElementById('main-zone');
    new Spinner(jc_spinner_opts).spin(target);