# gestion des optgroup du formulaire bridge pour gérer la cohérence entre 
# le livre sélectionné et la natue choisie

bridge_natures_selection = ->
  book_id = $('#bridge_income_book_id option:selected').val()
  # on désactive tous les optgroup
  $('#bridge_nature_name optgroup').attr('disabled', true);
  # avant de réactiver celui qui correspond au livre sélectionné
  $('#bridge_nature_name optgroup[data-id="'+book_id+'"]').attr('disabled', false)
  
$ ->
  # gestion des natures
  bridge_natures_selection() if $('form #bridge_income_book_id')? 
  $('form #bridge_income_book_id').change ->
    bridge_natures_selection()