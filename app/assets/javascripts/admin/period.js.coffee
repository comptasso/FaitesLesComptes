
fnMessageAttente= (mess)->
  $('#message-d-attente').text(mess)

jQuery ->
  $('#new_period #period-button').click -> 
    $('.inner-champ').block({ message: '<h4 id="message-d-attente">Juste un instant...</h4>' })
    window.setTimeout(-> 
                        $('#message-d-attente').text('Création du plan de comptes...')
                      1500)
    window.setTimeout(-> 
                        $('#message-d-attente').text('Préparation des modèles de rapport...')
                      3000)      