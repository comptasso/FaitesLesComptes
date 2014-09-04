"use strict";
/*global document, $, jQuery, Spinner, window, small_spinner_opts*/

jQuery(function () {
    if ($('#sheets_message_info').length !== 0) {
        var spinner = new Spinner(small_spinner_opts).spin(document.getElementById('message_spinner'));
        var heref = window.location.href;
        var polling = heref.replace('sheets?', 'sheets/values_ready?');

        setInterval(function () {
            $("#sheets_message_info").text($("#sheets_message_info").text() + '.');
        }, 1000);
        $("#sheets_message_info").smartupdater({
            url: polling,
            minTimeout: 2000, // 2 seconds
            smartStop: {active: true, monitorTimeout: 1000} // ce qui permet d'arrêter le polling
            // automatiquement dès que l'on masque la zone de message
        }, function (data) {
            if (data === "ready") {
                spinner.stop();
                $("#sheets_message_info").text("Fin du pré traitement...");
                window.location = heref;
            }
        }
            );


    }
});

