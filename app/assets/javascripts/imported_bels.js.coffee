# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Vérifie que la ligne a ses champs destination_id, nature_id et 
# payment_mode rempli. Alors affiche le bouton nouveau qui autrement est caché.
#
check_ibel_complete = (row) ->
  # lecture des 3 champs
  t = row.find('span[data-attribute="destination_id"]')
  u = row.find('span[data-attribute="nature_id"]')
  v = row.find('span[data-attribute="payment_mode"]')
  # un des trois est-il rempli avec la valeur par défaut
  complete = !(/—/.test(t.text()) || /—/.test(u.text()) || /—/.test(v.text()))
  # les transferts n'ont pas de destination ni de nature, on ne test que sur
  # payment_mode
  #console.log(row.find('td.cat span').text().trim())
  if row.find('td.cat span').text().trim() == 'T'
    complete = !(/—/.test(v.text()))
    
  #console.log("ligne #{row.attr('id')} -  - complet ? : #{complete}")  
  # on affiche le lien nouveau si c'est OK  
  row.find('a[title="Nouveau"]').show() if complete
  
  
  
  

# remplace la data_collection de dest par celle de source
replace_collection = (source, dest) -> 
  dest.data('bestInPlaceEditor').values = JSON.parse(source.attr('data-collection'))
  dest.text('—')
  #
  console.log(dest.attr('data-collection'))
  console.log(source.attr('data-collection'))


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
    console.log('changement')
  # alors il faut remplacer le data_attributes par un data_attributes qui convient.
    pm.attr('data-cat', field.text()) # on met à jour le champ
  # Les attributes de réserve sont dans la vue dans un div#transfer et div#depenses
    if field.text() == 'T'
      replace_collection($('div#transfer'), pm)
      # TODO un tansfert n' pas de nature ni de destination donc on masque le champ
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
  $(".public_imported_bels .best_in_place").best_in_place()
  $('.public_imported_bels tr.importable').each ->
    if $(@).find('td.cat').text().trim() == 'T'
      $(@).find('td.destination span').hide()
      $(@).find('td.nature span').hide()
  $('.public_imported_bels .best_in_place').bind "ajax:success", ->
  # si l'attribut catégorie (Transfert, Remise, Débit, Crédit) a changé, on 
  # appelle la fonction qui va modifier les values du select de payment_mode
    refill_payment_mode_values($(@)) if $(@).attr('data-attribute') == 'cat'
    check_ibel_complete($(@).parents('tr'))
  
    
  