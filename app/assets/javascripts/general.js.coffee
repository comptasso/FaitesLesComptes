

# les options pour le spinner
# On crée ensuite un spinner suite par exemple à l'action click
#de la façon suivante.
#  $('#new_balance_button').click(function() {
#      var target = document.getElementById('new_compta_balance');
#      var spinner = new Spinner(opts).spin(target);
#    });


jc_spinner_opts = {
    lines: 13, # The number of lines to draw
    length: 7, # The length of each line
    width: 4, # The line thickness
    radius: 26, # The radius of the inner circle
    corners: 0.8, # Corner roundness (0..1)
    rotate: 0, # The rotation offset
    color: '#000', # #rgb or #rrggbb
    speed: 1, # Rounds per second
    trail: 60, # Afterglow percentage
    shadow: false, # Whether to render a shadow
    hwaccel: false, # Whether to use hardware acceleration
    className: 'spinner', # The CSS class to assign to the spinner
    zIndex: 2e9, # The z-index (defaults to 2000000000)
    top: '100px', # car auto fait qu'on ne voit pas le spinner si le document affiché est long 
    # il se place au milieu de la zone donc alors invisible.
    left: 'auto' # Left position relative to parent in px
  }


# méthode permettant d'afficher un spinner lorsqu'on clique 
# sur un élément qui a pour classe 'with_spinner', généralement un lien ou 
# un bouton.
#
# La cible est la zone principale et les options (jc_spinner_opts) sont définies
# ci_dessus
jQuery ->
  $('.with_spinner').click ->
    target = document.getElementById('main-zone')
    new Spinner(jc_spinner_opts).spin(target)
    