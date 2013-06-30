"use strict";
/*jslint browser: true */
/*global $, jQuery */

//var jQuery, $;

jQuery(function () {
    $('.admin_accounts .data_table').dataTable(
        {
            "sDom": "lfrtip",
            "sPaginationType": "bootstrap",
            "oLanguage": {
                "sUrl": "/frenchdatatable.txt"
            },
            "aoColumns": [
                {
                    "sType": "string"
                },
                null,
                null,
                null,
                {
                    "bSortable": false
                }
            ],
            "iDisplayLength": 10,
            "aLengthMenu": [[10, 25, 50, -1], [10, 25, 50, "Tous"]]
        }
    );
});

// série de fonction utilisée pour associer un compte aux natures
// un compte de classe 7 ne peut être associé qu'à une nature de type recettes
// de même un compte de classe 6 avev une nature de type dépenses
//
function desac_recettes() {
    $('optgroup[label=Recettes] option').attr('disabled', 'disabled');
}

function desac_depenses() {
    $('optgroup[label=Dépenses] option').attr('disabled', 'disabled');
}
function active_recettes() {
    $('optgroup[label=Recettes] option').attr('disabled', false);
}

function active_depenses() {
    $('optgroup[label=Dépenses] option').attr('disabled', false);
}

function toggle_recettes_depenses(acc) {
    active_depenses();
    active_recettes();
    if (acc.match(new RegExp('^' + '6'))) {
        desac_recettes();
    }
    if (acc.match(new RegExp('^' + '7'))) {
        desac_depenses();
    }

}


jQuery(function () {
    var acc;
    if ($('.accounts input#account_number').length !== 0) {
        acc = $('input#account_number').val();
        toggle_recettes_depenses(acc);
        $('input#account_number').change(function () {
            toggle_recettes_depenses($('input#account_number').val());
        });
    }
});
