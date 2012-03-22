/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
// mise en forme de la table index des organismes
jQuery(function () {
    if ($('.admin_organisms .data_table').length !== 0) {
        /* Table initialisation */
        $('h3').html('bonjour');
        $('.admin_organisms .data_table').dataTable({
            "sDom": "<'row'r>t",
            "bAutoWidth": false,
            "oLanguage": {
                "sUrl": "/frenchdatatable.txt"
            }
        });
    }
});

