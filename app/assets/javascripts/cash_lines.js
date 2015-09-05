"use strict";
/*jslint browser: true */
/*global $, jQuery */


// var jQuery, $, stringToFloat, window;

// mise en forme des tables de lignes
jQuery(function () {
    if ($('.public_cash_lines .cash_lines_table').length !== 0) {
        $('.public_cash_lines .cash_lines_table').dataTable(
                {
                    "aoColumnDefs": [
                {
                    "bSortable": false,
                    "aTargets": ['actions' ]
                },
                {
                    "sType": "date-euro",
                    "asSortable": ['asc', 'desc'],
                    "aTargets": ['date-euro'] // les colonnes date au format français ont la classe date-euro
                }],
                    
                 
                    
                    "fnFooterCallback": function (nRow, aaData, iStart, iEnd, aiDisplay) {
                     
                        var i = 0,
                            iTotalDebit = 0,
                            iTotalCredit = 0.0,
                            iPageDebit = 0.0,
                            iPageCredit = 0.0,
                            nCells;
                        for (i = 0; i < aaData.length; i += 1) {
                            iTotalDebit += stringToFloat(aaData[i][6]);
                        }

                        
                        for (i = iStart; i < iEnd; i += 1) {
                            iPageDebit += stringToFloat(aaData[aiDisplay[i]][6]);
                        }
                        for (i = 0; i < aaData.length; i += 1) {
                            iTotalCredit += stringToFloat(aaData[i][7]);
                        }
                       
                        for (i = iStart; i < iEnd; i += 1) {
                            iPageCredit += stringToFloat(aaData[aiDisplay[i]][7]);
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



