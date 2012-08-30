"use strict";
/*jslint browser: true */
var jQuery, $, stringToFloat, numberWithPrecision;



function drawDataTable() {
    $('.compta_listings .listing_data_table').dataTable({
        "sDom": "lfrtip",
        "bAutoWidth": false,
        "sPaginationType": "bootstrap",
        "oLanguage": {
            "sUrl": "/frenchdatatable.txt"
        },
        "aoColumnDefs": [
            {
                "sType": "date-euro",
                "asSortable": ['asc', 'desc'],
                "aTargets": ['date-euro'] // les colonnes date au format français ont la classe date-euro
            }],
        "iDisplayLength": 10,
        "aLengthMenu": [[10, 10, 25, 50, -1], [10, 10, 25, 50, "Tous"]],
        "bStateSave": true,
        "fnStateSave": function (oSettings, oData) {
            localStorage.setItem('DataTables_' + window.location.pathname, JSON.stringify(oData));
        },
        "fnStateLoad": function (oSettings) {
            return JSON.parse(localStorage.getItem('DataTables_' + window.location.pathname));
        },
        "fnFooterCallback": function (nRow, aaData, iStart, iEnd, aiDisplay) {
            /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */
            var i = 0, iPageDebit = 0.0, iPageCredit = 0.0;
//            for (i = 0; i < aaData.length; i += 1) {
//                iTotalDebit += stringToFloat(aaData[i][5]);
//            }

            /* Calculate the market share for browsers on this page */
            for (i = iStart; i < iEnd; i += 1) {
                iPageDebit += stringToFloat(aaData[aiDisplay[i]][5]);
            }

//            for (i = 0; i < aaData.length; i += 1) {
//                iTotalCredit += stringToFloat(aaData[i][6]);
//            }

            /* Calculate the market share for browsers on this page */
            for (i = iStart; i < iEnd; i += 1) {
                iPageCredit += stringToFloat(aaData[aiDisplay[i]][6]);
            }

            /* Modify the footer row to match what we want */
//            nCells = nRow.getElementsByTagName('th');
            $('#tdebit').text(numberWithPrecision(iPageDebit));
            $('#tcredit').text(numberWithPrecision(iPageCredit));
//            nCells[1].innerHTML =  iPageDebit.toFixed(2) + '<br/>' + iTotalDebit.toFixed(2);
//            nCells[2].innerHTML =  iPageCredit.toFixed(2) + '<br/>' + iTotalCredit.toFixed(2);

        }
    });
}

// mise en forme des tables de lignes
jQuery(function () {
    $('.compta_listings #div-movements').hide();
    drawDataTable();
    $('.compta_listings #show-soldes').toggle(function () {
        $('#div-movements').show();
        $('a#show-soldes').text('masquer les soldes');
    },
        function () {
            $('#div-movements').hide();
            $('a#show-soldes').text('afficher les soldes');
        });
});

