"use strict";
/*jslint browser: true */
var jQuery, $, stringToFloat, window;

// mise en forme des tables de lignes
jQuery(function () {
    if ($('.public_cash_lines .cash_lines_table').length !== 0) {
        var oTable = $('.public_cash_lines .cash_lines_table').dataTable(
                {
                    "sDom": "lfrtip",
                    "sPaginationType": "bootstrap",
                    "oLanguage": {
                        "sUrl": "/frenchdatatable.txt"
                    },
                    "aoColumns": [
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        {
                            "bSortable": false
                        }
                    ],
                    "iDisplayLength": 15, // affichage par défaut
                    "aLengthMenu": [[15, 25, 50, -1], [15, 25, 50, "Tous"]], // le menu affichage
                    "bStateSave": true, // pour pouvoir sauvegarder l'état de la table
                    "fnStateSave": function (oSettings, oData) { //localStorage avec un chemin pour que les
                      // paramètres spécifiques  aux cash_lines soient mémorisés.
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
                        var i = 0,
                            iTotalDebit = 0,
                            iTotalCredit = 0.0,
                            iPageDebit = 0.0,
                            iPageCredit = 0.0,
                            nCells;
                        for (i = 0; i < aaData.length; i += 1) {
                            iTotalDebit += stringToFloat(aaData[i][5]);
                        }

                        /* Calculate the market share for browsers on this page */
                        for (i = iStart; i < iEnd; i += 1) {
                            iPageDebit += stringToFloat(aaData[aiDisplay[i]][5]);
                        }
                        for (i = 0; i < aaData.length; i += 1) {
                            iTotalCredit += stringToFloat(aaData[i][6]);
                        }
                        /* Calculate the market share for browsers on this page */
                        for (i = iStart; i < iEnd; i += 1) {
                            iPageCredit += stringToFloat(aaData[aiDisplay[i]][6]);
                        }

                        /* Modify the footer row to match what we want */
                        nCells = nRow.getElementsByTagName('th');
                        nCells[1].innerHTML =  iPageDebit.toFixed(2) + '<br/>' + iTotalDebit.toFixed(2);
                        nCells[2].innerHTML =  iPageCredit.toFixed(2) + '<br/>' + iTotalCredit.toFixed(2);

                    }
                }
            );
    }
});



