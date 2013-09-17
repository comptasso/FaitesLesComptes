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
  
$ ->
  # on affiche les totaux de la table des bank_extract_lines dans le haut de la colonne
  showSum() if $('#bels_table')?
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
    

