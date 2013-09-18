# pointage doit d'abord masquer l'icone de verrouillage du relevé si 
# les soldes ne collent pas


# afficher le solde de la colonne des bels credit
flcSum= (selector)->
  total = 0
  $(selector).each ->
    total += stringToFloat($(this).text()) || 0
  total
  
showSum= ->
  $('#bels_total_debit').text($f_numberWithPrecision(flcSum('#bels .debit')))
  $('#bels_total_credit').text($f_numberWithPrecision(flcSum('#bels .credit')))
  
spreadDebit= ->
  flcSum('#bels .debit') - stringToFloat($('span#total_debit').text())
  
spreadCredit= ->
  flcSum('#bels .credit') - stringToFloat($('span#total_credit').text())
  
checkSum= ->
  # on affiche les totaux de la table des bank_extract_lines dans le haut de la colonne
  showSum() 
  # on gère les panneaux dangers et l'affichage de l'écart
  if Math.abs(spreadDebit()) < 0.001
    $('#img_danger_total_debit').hide()
  else
    $('#img_danger_total_debit').show().attr('title', "Ecart de pointage de #{spreadDebit().toFixed(2)}")
  
  if Math.abs(spreadCredit()) < 0.001
    $('#img_danger_total_credit').hide()
  else
    $('#img_danger_total_credit').show().attr('title', "Ecart de pointage de #{spreadCredit().toFixed(2)}")
    
  # si debit et credit sont égaux on peut afficher l icone de verrouillage   
  if Math.abs(spreadDebit()) < 0.001 && Math.abs(spreadCredit()) < 0.001
    $('#lock_bank_extract').show()
  else
    $('#lock_bank_extract').hide()  
    
# fait passer une ligne de la droite (les lines to point) vers la gauche (les 
# bank_extract_lines). Puis recalcule les sommes et refait l'affichage des 
# icones danger et des écarts.
#
# Lorsque l'image est cliquée, on prend sa ligne (balise tr), on la transfère
# dans l'autre table. Puis on cherche l'image, on désactive la fonction ltpsTobels
# pour la remplacer par sa réciproque (belsToltps) et enfin on change l'icone.
#
# Il ne reste plus qu'à recalculer les totaux.
#
ltpsTobels=  ->
  $(this).parents('tr').appendTo($('#bels_table tbody')).
    find('img.transfert').off('click', ltpsTobels).on('click', belsToltps).
    attr('src', '/assets/icones/retirer.png')
  activeEnregistrer()   
  checkSum()

# fait passer une ligne de la gauche (les bank_extract_lines) vers la droite (les 
# lines_to_point). Puis recalcule les sommes et refait l'affichage des 
# icones danger et des écarts
belsToltps= ->
  $(this).parents('tr').appendTo($('#ltps_table tbody')).
    find('img.transfert').off('click', belsToltps).on('click', ltpsTobels).
    attr('src', '/assets/icones/ajouter.png')
  activeEnregistrer()   
  checkSum()
  
# fonction permettant de construire une liste des bank_extract_lines
# en notant la position et l'id de la ligne
jsonfos= ->
  a = {lines: {} }
  $('#bels tr').each( (index) ->
    console.log($(this).attr('id'))
    #newline = 'line_'+index
    a.lines[index] = $(this).attr('id')
    )
  a
 
 # a pour effet de changer le statut du bouton Enregistrer
 activeEnregistrer= ->
   $('#enregistrer').prop('disabled', false).removeClass('btn-disabled').addClass('btn-success')
   
   

$ '#ltps_table', ->
  checkSum() 
  # ici on attache à l'image ajouter.png une fonction qui déplace la ligne correspondante en bas
  # de la table des bels, ou qui fait l'inverse, replace la ligne à droite (mais alors
  # elle n'est plus ordonnée (il faudra rafraichir la page pour reordonner)
  $('#ltps_table tbody').on('click', 'img.transfert', ltpsTobels)
  $('#bels_table tbody').on('click', 'img.transfert', belsToltps)
        
  console.log(JSON.stringify(jsonfos()))

  # LA TABLE DES BELS est triable par drag and drop
  $("#bels").sortable
    connectWith: ".connectedSortable",
    items: "tr",
    update: activeEnregistrer
    
    # associer au bouton 'Enregistrer' un appel de fonction pour enregistrer les lignes 
  # pointées.
  $('#enregistrer').click -> 
    $.ajax({
      url: window.location.pathname.replace('pointage', 'enregistrer'),
      type: 'post',
      data: jsonfos(),
      success: ->
      })
  
  # TODO : griser le bouton tant qu'il n'y a pas eu de modif et l'activer à la 
  # première modif. Un enregistrement doit le regriser.


