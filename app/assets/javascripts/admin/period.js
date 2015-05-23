/* 
 * A pour effet d'afficher deux trois messages d'attente pendant que la 
 * création de l'exercice se fait en arrière plan
 * 
 */
 jQuery(function () {
   $('#new_period') //id du formulaire de création d'un exercice
    .bind("ajax:beforeSend", function(evt, xhr, settings){
      $('.inner-champ').block({ message: '<h4 id="message-d-attente">Juste un instant...</h4>' });
      setTimeout(function() {
        $('#message-d-attente').text('Création du plan de comptes...');
      }, 2000);
      setTimeout(function() {
        $('#message-d-attente').text('Préparation des modèles de rapport...');
      }, 4000);                               
    });   
});