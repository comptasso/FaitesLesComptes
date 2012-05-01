/* mise en forme des tables de lignes */
"use strict";
/*jslint browser: true */

var $, jQuery;
jQuery(function () {
    if ($('.natures .data_table').length !== 0) {
        var oTable, nCells;
        oTable = $('.natures .data_table').dataTable({
            "oLanguage": {
                "sUrl": "/frenchdatatable.txt"
            }
        });

        nCells = $('tbody tr:nth-child(1) td').length;
        $('td', oTable.fnGetNodes()).hover(function () {

            var iCol = $('td', this.parentNode).index(this) % nCells,
                nTrs = oTable.fnGetNodes();
            $('td:nth-child(' + (iCol + 1) + ')', nTrs).addClass('highlighted');
        }, function () {
            $('td.highlighted', oTable.fnGetNodes()).removeClass('highlighted');
        });
    }
});

