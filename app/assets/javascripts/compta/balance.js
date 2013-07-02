"use strict";
/*jslint browser: true */
/*global $, jQuery, jc_spinner_opts, Spinner */

var fileDownloadCheckTimer;
var unspin

jQuery(function () {
    $('#new_balance_button').click(function () {
        var target = document.getElementById('new_compta_balance');
        new Spinner(jc_spinner_opts).spin(target);
    });

    

});


 