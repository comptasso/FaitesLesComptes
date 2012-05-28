"use strict";
var jQuery, $, stringToFloat;

// mise en forme des tables de lignes
jQuery(function () {
    if ($('.public_cash_lines .data_table').length !== 0) {
        var oTable = $('.public_cash_lines .data_table').dataTable(
                {
                    "sDom": "<'row-fluid'<'span9'l><'span3'f>r>t<'row-fluid'<'span9'i><'span3'p> >",
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
                        {
                            "bSortable": false
                        }
                    ],

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
                            iTotalDebit += stringToFloat(aaData[i][4]);
                        }

                        /* Calculate the market share for browsers on this page */
                        for (i = iStart; i < iEnd; i += 1) {
                            iPageDebit += stringToFloat(aaData[aiDisplay[i]][4]);
                        }
                        for (i = 0; i < aaData.length; i += 1) {
                            iTotalCredit += stringToFloat(aaData[i][5]);
                        }
                        /* Calculate the market share for browsers on this page */
                        for (i = iStart; i < iEnd; i += 1) {
                            iPageCredit += stringToFloat(aaData[aiDisplay[i]][5]);
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



