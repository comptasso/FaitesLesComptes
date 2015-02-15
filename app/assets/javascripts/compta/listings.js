"use strict";
/*jslint browser: true */
/*global $, jQuery */

//var jQuery, $, stringToFloat, $f_numberWithPrecision;



function drawDataTable() {
    $('.compta_listings .listing_data_table').dataTable({
        "bAutoWidth": false,
        "aoColumnDefs": [
            {
                "sType": "date-euro",
                "asSortable": ['asc', 'desc'],
                "aTargets": ['date-euro'] // les colonnes date au format français ont la classe date-euro
            }],
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

            /* Calculate the market share for browsers on this page */
            for (i = iStart; i < iEnd; i += 1) {
                iPageDebit += stringToFloat(aaData[aiDisplay[i]][7]);
            }



            /* Calculate the market share for browsers on this page */
            for (i = iStart; i < iEnd; i += 1) {
                iPageCredit += stringToFloat(aaData[aiDisplay[i]][8]);
            }

            /* Modify the footer row to match what we want */
//            nCells = nRow.getElementsByTagName('th');
            $('#tdebit').text($f_numberWithPrecision(iPageDebit));
            $('#tcredit').text($f_numberWithPrecision(iPageCredit));
//            nCells[1].innerHTML =  iPageDebit.toFixed(2) + '<br/>' + iTotalDebit.toFixed(2);
//            nCells[2].innerHTML =  iPageCredit.toFixed(2) + '<br/>' + iTotalCredit.toFixed(2);

        }
    });
}

// mise en forme des tables de lignes
jQuery(function () {
  if ($('body.compta_listings').length >= 1) {
    $('body.compta_listings #div-movements').hide();
    drawDataTable();
    $('body.compta_listings #show-soldes').click(function () {
        $('#div-movements').toggle();
        if ($('a#show-soldes').text() === 'Masquer les soldes') {
            $('a#show-soldes').text('Afficher les soldes');
        }
        else {
            $('a#show-soldes').text('Masquer les soldes');
        }
    });
  }
});

