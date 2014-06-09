jQuery ->
  $('#new_admin_room').click -> 
    $('.inner-champ').block({ message: '<h4 id="message-d-attente">Juste un instant...</h4>' })
    window.setTimeout(-> 
                        $('#message-d-attente').text('Création de votre espace de données...')
                      1500)
    window.setTimeout(-> 
                        $('#message-d-attente').text('Création des tables et initialisation...')
                      3000)      