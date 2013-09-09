# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# L'objet de ce fichier est de gérer l'affichage des logiques du formulaire.
# Ainsi mode = Espèces doit avoir comme conséquence de disable les comptes bancaires pour la contrepartie
# De même il doit y avoir correspondance entre le type de Livre et les Natures (Recettes ou dépenses).
# 
#
# le formulaire est fait de telle façon que les options des livres ont une classe incomebook ou outcomebook
# ce qui permet de faire le lien avec les natures.
natures_selection = ->
  if $('#mask_book_id option:selected').attr('class') == 'outcomebook'
    $('optgroup[label=Dépenses] option').attr('disabled', false)
    $('optgroup[label=Recettes] option').attr('disabled', true)
  else
    $('optgroup[label=Recettes] option').attr('disabled', false);
    $('optgroup[label=Dépenses] option').attr('disabled', true);
    
counterpart_selection = ->
  
  
  if $('form #mask_mode option:selected').val() == 'Espèces'
    $('optgroup[label=Caisses] option').attr('disabled', false)
    $('optgroup[label=Banques] option').attr('disabled', true)
  else if $('form #mask_mode option:selected').val() != ''
    $('optgroup[label=Banques] option').attr('disabled', false);
    $('optgroup[label=Caisses] option').attr('disabled', true);
  else
    $('optgroup[label=Banques] option').attr('disabled', false);
    $('optgroup[label=Caisses] option').attr('disabled', false);
    
  if $('form #mask_mode option:selected').val() == 'Chèque' && $('#mask_book_id option:selected').attr('class') == 'incomebook'
    $('form #mask_counterpart option').attr('disabled', true)
    $("form #mask_counterpart option[value='"+'Chèque à l\'encaissement'+"']").attr('disabled', false)
    
  if $('form #mask_mode option:selected').attr('class') == 'outcomebook' || $('form #mask_mode option:selected').val() != 'Chèque'
    $("form #mask_counterpart option[value='"+'Chèque à l\'encaissement'+"']").attr('disabled', true)
  
    

$ ->
  # gestion des natures
  natures_selection() if $('form #mask_book_id')? 
  $('form #mask_book_id').change ->
    natures_selection()
    counterpart_selection() # car le changement de livre influe sur le mode pour chèque à l'encaissement
    
  # gestion du mode  
  counterpart_selection() if $('form #mask_counterpart')
  $('form #mask_mode').change ->
    counterpart_selection()
  