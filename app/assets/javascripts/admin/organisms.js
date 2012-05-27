/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
// mise en forme de la table index des organismes
jQuery(function () {
    if ($('.admin_organisms .data_table').length !== 0) {
        /* Table initialisation */
        
        $('.admin_organisms .data_table').dataTable({
            "sDom": "<'row-fluid'<'span6'l><'span6' f> >rt<'row-fluid'p>",
            "bAutoWidth": false
//            ,
//            "oLanguage": {
//                "sUrl": "/frenchdatatable.txt"
//            }
        });
    }
});

