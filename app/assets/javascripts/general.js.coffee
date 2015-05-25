




# méthode permettant d'afficher un spinner lorsqu'on clique 
# sur un élément qui a pour classe 'with_spinner', généralement un lien ou 
# un bouton.
#
# La cible est la zone principale et les options (jc_spinner_opts) sont définies
# dans application.js
jQuery ->
  $('.with_spinner').click ->
    target = document.getElementById('main-zone')
    new Spinner(jc_spinner_opts).spin(target)
