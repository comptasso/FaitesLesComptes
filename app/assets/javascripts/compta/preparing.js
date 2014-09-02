"use strict";
/*global document, $, jQuery */
jQuery(function () {
  var spinner = new Spinner(small_spinner_opts).spin(document.getElementById('message_spinner'));
  var heref = window.location.href;
  var polling = heref.replace('sheets?', 'sheets/values_ready?');
  console.log(heref);
  $("#message_info").smartupdater({
    url : polling,
    minTimeout: 2000,  // 2 seconds
    smartStop: {active:true, monitorTimeout:1000} // ce qui permet d'arrêter le polling
    // automatiquement dès que l'on masque la zone de message
    }, function (data) {
        if (data === 'processing') {
          $("#message_info").text("Toujours en cours...");
        }
        if (data === "ready") {
          spinner.stop();
          $("#message_info").text("Fin du pré traitement...");
          
          setTimeout(function() {
            $("#message").hide();
            }, 2000);
          setTimeout(function() {
            
            window.location = heref;
            }, 2100);
          }
    }
);
  
  
  
});

