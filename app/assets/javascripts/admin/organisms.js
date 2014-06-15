// permet d'afficher un message d'attente dans une zone ayant l'id message-d-attente
//
function MessageAttente(mess) {
  $('#message-d-attente').text(mess);
}

jQuery(function () {
  $('#new_admin_room').submit(function () {
    $('.inner-champ').block({ message: '<h4 id="message-d-attente">Juste un instant...</h4>' });
    setTimeout(function () {
                 MessageAttente('Création de votre espace de données...');
                      }, 
                      1000);
                      
    setTimeout(function () {
                 MessageAttente('Création des tables et initialisation...');
                      }, 
                      2000);
      });      

});