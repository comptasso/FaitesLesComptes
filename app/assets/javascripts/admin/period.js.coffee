jQuery ->
  $('#new_period #period-button').click -> 
    $('.inner-champ').block({ message: '<h4 id="message-d-attente">Juste un instant...</h4>' })
    window.setTimeout(-> 
                        MessageAttente('Création du plan de comptes...')
                      1500)
    window.setTimeout(-> 
                        MessageAttente('Préparation des modèles de rapport...')
                      3000)      