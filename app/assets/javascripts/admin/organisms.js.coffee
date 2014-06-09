# permet d'afficher un message d'attente dans une zone ayant l'id message-d-attente
# 
@MessageAttente = (mess)->
  $('#message-d-attente').text(mess)



jQuery ->
  $('#new_admin_room').click -> 
    $('.inner-champ').block({ message: '<h4 id="message-d-attente">Juste un instant...</h4>' })
    window.setTimeout(-> 
                        MessageAttente('Création de votre espace de données...')
                      1500)
    window.setTimeout(-> 
                        MessageAttente('Création des tables et initialisation...')
                      3000)      