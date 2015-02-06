"use strict";
/*jslint browser: true */
/*global $, jQuery */

//var jQuery, $;



jQuery(function () {
//    // la table des comptes sans ou avec secteur 
//    var table_account, table_sectored_account, col_types;
    var table_account, col_types;
    table_account = [
        {
            "sType": "string"
        },
        null,
        null,
        null,
        {
            "bSortable": false
        }
    ];

    if ($('.admin_accounts .data_table thead').attr('class') === 'sectored') {
        col_types = [{
            "sType": "string"
        }].concat(table_account);
    } else {
        col_types = table_account;
    }
    $('.admin_accounts .data_table').dataTable(
        {
            "aoColumns": col_types,
            "iDisplayLength": 10,
            "aLengthMenu": [[10, 25, 50, -1], [10, 25, 50, "Tous"]]
        }
    );
});


