"use strict";
/*jslint browser: true */
/*global $, jQuery */

//var jQuery, $, stringToFloat;

/* Table initialisation */

$(document).ready(function () {
	$('#transfer-table').dataTable({
        
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
    $('#transfer form').on('change', '#transfer_compta_lines_attributes_0_account_id', $f_transfer_from_account);
    $('#transfer form').on('change', '#transfer_compta_lines_attributes_1_account_id', $f_transfer_to_account);
});