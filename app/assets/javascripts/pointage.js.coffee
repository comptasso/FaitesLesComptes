# pointage doit d'abord masquer l'icone de verrouillage du relevé si 
# les soldes ne collent pas


# afficher le solde d'une collection de nombres en format français (20,27; 5,00; ...)
flcSum= (selector)->
  total = 0
  $(selector).each ->
    total += stringToFloat($(this).text()) || 0
  total
  
# affiche le total des colonnes débit et credit des lignes pointées
showSum= ->
  $('#bels_total_debit').text($f_numberWithPrecision(flcSum('#bels .debit')))
  $('#bels_total_credit').text($f_numberWithPrecision(flcSum('#bels .credit')))
  
# donne l'écart entre le total des lignes débit pointées et le montant débit du relevé
spreadDebit= ->
  flcSum('#bels .debit') - stringToFloat($('span#total_debit').text())
 
# donne l'écart entre le total des lignes crédit pointées et le montant crédit du relevé 
spreadCredit= ->
  flcSum('#bels .credit') - stringToFloat($('span#total_credit').text())
  
# fonction de contrôle des sommes
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
  
  # on masque l icone de verrouillage si les totaux ne sont pas conformes
  if Math.abs(spreadDebit()) > 0.001 || Math.abs(spreadCredit()) > 0.001
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
  ligne = $(this).parents('tr').appendTo($('#bels_table tbody'))
  ligne.find('img.transfert').off('click', ltpsTobels).on('click', belsToltps).
    attr('src', '/assets/icones/retirer.png')
  ligne.find('a.icon_menu').hide() # on masque les icones edition et suppression de la ligne
  activeEnregistrer() if "disabled" in $('#enregistrer').attr('class').split(' ')     
  checkSum()

# fait passer une ligne de la gauche (les bank_extract_lines) vers la droite (les 
# lines_to_point). Puis recalcule les sommes et refait l'affichage des 
# icones danger et des écarts
belsToltps= ->
  ligne = $(this).parents('tr').appendTo($('#ltps_table tbody'))
  ligne.find('img.transfert').off('click', belsToltps).on('click', ltpsTobels).
    attr('src', '/assets/icones/ajouter.png')
  activeEnregistrer()  if "disabled" in $('#enregistrer').attr('class').split(' ') 
  checkSum()
  
# fonction permettant de construire une liste des bank_extract_lines
# en notant la position et l'id de la ligne. Utilisé pour l'argument data de 
# la fonction enregister
jsonfos= ->
  a = {lines: {} }
  $('#bels tr').each( (index) ->
    a.lines[index] = $(this).attr('id')
    )
  a
 
# a pour effet de changer le statut du bouton Enregistrer
activeEnregistrer= ->

  $('#enregistrer').prop('disabled', false).removeClass('disabled').addClass('btn-success')
  $('#message').empty()
  hide_icons() # masquage des icones
   
# masque les icones edit, supprimer des écritures ainsi que l'icone plus de la boite modale
# qui permet d'écrire une nouvelle ligne
hide_icons= ->
  $('a.icon_menu').hide()

# affiche les icones edit, supprimer des écritures ainsi que l'icone plus de la boite modale
# qui permet d'écrire une nouvelle ligne
show_icons= ->
  $('a.icon_menu').show()

# FONCTION PRINCIPALE
$ ->
  if $('#ltps_table').length # ce if est là car sinon checksum agit aussi dans la vue index du controller
  # bank_extract_lines
  
    # contrôle des totaux et affichage des balises dangers et des écarts
    checkSum() 
    
    # ici on attache à l'image ajouter.png une fonction qui déplace la ligne correspondante en bas
    # de la table des bels, ou qui fait l'inverse, replace la ligne à droite (mais alors
    # elle n'est plus ordonnée (il faudra rafraichir la page pour reordonner)
    $('#ltps_table tbody').on('click', 'img.transfert', ltpsTobels)
    $('#bels_table tbody').on('click', 'img.transfert', belsToltps)



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
          $('#enregistrer').prop('disabled', true).removeClass('btn-success').addClass('disabled')
          show_icons()
          # si debit et credit sont égaux  et si les infos ont bien été enregistrées, 
          # on peut alors afficher l icone de verrouillage   
          if Math.abs(spreadDebit()) < 0.001 && Math.abs(spreadCredit()) < 0.001
            $('#lock_bank_extract').show()
          else
            $('#lock_bank_extract').hide()  

        error: ->
          alert('Une erreur s\'est produite')
        })
  
  


