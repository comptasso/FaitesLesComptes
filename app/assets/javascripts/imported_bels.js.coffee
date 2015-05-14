# Les imported_bels permettent de créer des écritures à partir d'un relevé 
# de compte. 
# Il est nécessaire évidemment de compléter ou de modifier les champs 
# Ces modifications se font à l'aide du gem best_in_place. 
#
# Il peut y avoir 3 types d'écritures : 
# - D pour les dépenses
# - C pour les recettes 
# - et T pour les virements internes qui seront donc écrits dans un journal 
# d'OD.
# 
#

# lit l'attribut date-min et date-max du body de la table
# et affecte ces valeurs aux date-picker
set_date_limits = ->
  datemin = $('tbody').attr('data-mindate')
  datemax = $('tbody').attr('data-maxdate')
  $.datepicker.setDefaults
    dateFormat: 'dd/mm/yy',
    minDate: datemin,
    maxDate: datemax



# Vérifie que la ligne a ses champs destination_id, nature_id et 
# payment_mode rempli. Pour les transferts, on ne demande qu'à avoir la 
# colonne PaymentMode. 
# Alors affiche le bouton nouveau qui autrement est caché.
#
check_ibel_complete = (row) ->
  # lecture des 3 champs
  t = row.find('span[data-bip-attribute="destination_id"]')
  u = row.find('span[data-bip-attribute="nature_id"]')
  v = row.find('span[data-bip-attribute="payment_mode"]')
  # un des trois est-il rempli avec la valeur par défaut
  complete = !(/-/.test(t.text()) || /-/.test(u.text()) || /-/.test(v.text()))
  # les transferts n'ont pas de destination ni de nature, on ne test que sur
  # payment_mode
  complete = !(/-/.test(v.text())) if row.find('td.cat span').text().trim() == 'T'
  # on affiche le lien nouveau si c'est OK 
  if complete
    row.find('a.ibel_write').show()
  else
    row.find('a.ibel_write').hide()
  

# remplace la data_collection de dest par celle de source et remet le champ 
# dest à un long dash. 
# 
replace_collection = (source, dest) -> 
  dest.data('bestInPlaceEditor').values = JSON.parse(source.attr('data-collection'))
  dest.text('-')
  


# L'objectf de cette méthode est de modifier les valeurs du champ payment_mode
# en cas de modification du champ catégorie. 
#
# Le cas pratique est celui ou un T est transforé en D et vice versa
#
refill_payment_mode_values = (field) ->
  # on cherche payment_mode
  pm = field.parents('tr').find('td.payment_mode span.best_in_place')
  # S'il y a une différence entre data-cat de payment_mode et la valeur de cat
  if field.text() != pm.attr('data-cat')
  # alors il faut remplacer le data_attributes par un data_attributes qui convient.
    pm.attr('data-cat', field.text()) # on met à jour le champ
  # Les attributes de réserve sont dans la vue dans un div#transfer et div#depenses
    if field.text() == 'T'
      replace_collection($('div#transfer'), pm)
      # un tansfert n' pas de nature ni de destination donc on masque le champ
      # destination_id et nature_id
      field.parents('tr').find('td.destination span.best_in_place').hide()
      field.parents('tr').find('td.nature span.best_in_place').hide()
    else
      replace_collection($('div#depenses'), pm)
      field.parents('tr').find('td.destination span.best_in_place').show()
      field.parents('tr').find('td.nature span.best_in_place').show()
    
# l'icone + doit être affichée lorsque les champs sont tous remplis 
# Il faudra donc surveiller l'évolution de chacun des champs un bind_succes
# de best_in_place  
      
$ ->
  set_date_limits()
  $(".public_imported_bels .best_in_place").best_in_place()
  $('.public_imported_bels tr.importable').each ->
    if $(@).find('td.cat').text().trim() == 'T'
      $(@).find('td.destination span').hide()
      $(@).find('td.nature span').hide()
  $('.public_imported_bels .best_in_place').bind "ajax:success", ->
  # si l'attribut catégorie (Transfert, Remise, Débit, Crédit) a changé, on 
  # appelle la fonction qui va modifier les values du select de payment_mode
    refill_payment_mode_values($(@)) if $(@).attr('data-bip-attribute') == 'cat'
    check_ibel_complete($(@).parents('tr'))
  
    
  