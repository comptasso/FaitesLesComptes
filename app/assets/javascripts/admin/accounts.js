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


