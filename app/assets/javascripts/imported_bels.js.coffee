# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Vérifie que la ligne a ses champs destination_id, nature_id et 
# payment_mode rempli. Alors affiche le bouton nouveau qui autrement est caché.
#
check_ibel_complete = (row) ->
  
  t = row.find('span[data-attribute="destination_id"]').text()
  u = row.find('span[data-attribute="nature_id"]').text()
  v = row.find('span[data-attribute="payment_mode"]').text()
  
  complete = !(/—/.test(t) || /—/.test(u) || /—/.test(v))  
  
  row.find('a[title="Nouveau"]').show() if complete


# l'icone + doit être affichée lorsque les champs sont tous remplis 
# Il faudra donc surveiller l'évolution de chacun des champs un bind_succes
# de best_in_place
jQuery ->
  $('.best_in_place').bind "ajax:success", ->
    check_ibel_complete($(this).parents('tr'))
  
    
  