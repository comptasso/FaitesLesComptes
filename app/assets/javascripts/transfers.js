"use strict";
/*jslint browser: true */
/*global $, jQuery */

//var jQuery, $, stringToFloat;

/* Table initialisation */

$(document).ready(function () {
	$('#transfer-table').dataTable({
        "sDom": 'lfrtip',
        "sPaginationType": "bootstrap",
        "oLanguage": {
            "sUrl": "/frenchdatatable.txt"   // ce fichier est dans /public
        },
        "aoColumnDefs": [
            {
                "bSortable": false,
                "aTargets": ['actions' ]
            },
            {
                "sType": "date-euro",
                "asSortable": ['asc', 'desc'],
                "aTargets": ['date-euro'] // les colonnes date au format français ont la classe date-euro
            }]


	});
});

// lit la valeur qui est sélectionnée dans le champ from account
// et la disable pour sa propre liste d'option'
function $f_transfer_from_account() {
    var s = $('#transfer_compta_lines_attributes_0_account_id').val();
    $('#transfer_compta_lines_attributes_1_account_id option[value=' + s + ']').attr('selected', false);
}

function $f_transfer_to_account() {
    var s = $('#transfer_compta_lines_attributes_1_account_id').val();
    $('#transfer_compta_lines_attributes_0_account_id option[value=' + s + ']').attr('selected', false);
}

// gestion des champs select dans le form Transfert
jQuery(function () {
    if ($('#transfer form').length !== null) {
        $('#transfer_compta_lines_attributes_0_account_id').live('change', $f_transfer_from_account);
        $('#transfer_compta_lines_attributes_1_account_id').live('change', $f_transfer_to_account);
    }


});