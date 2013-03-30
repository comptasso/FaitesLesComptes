# Affiche le spinner quand on clique sur le bouton du formulaire
$ ->
  $('#new_general_book_button').click ->
    target = document.getElementById('new_compta_general_book');
    new Spinner(jc_spinner_opts).spin(target);