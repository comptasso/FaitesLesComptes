
"use strict";
/*jslint browser: true */
var jQuery, $, stringToFloat;

// mise en forme des tables de lignes
jQuery(function () {
    if ($('.lines_table').length !== 0) {
        $('.lines_table').dataTable({
            "sDom": "lfrtip",
         //   "sDom": "<'row-fluid'<'span9'l><'span3'f>r>t<'row-fluid'<'span8'i><'span4'p> >",
            "sPaginationType": "bootstrap",
            "bAutoWidth": false,
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
                null,
                null,
                {"bSortable": false}
            ],
            "iDisplayLength": 10,
            "aLengthMenu": [[10, 25, 50, -1], [10, 25, 50, "Tous"]],
            "bStateSave": true,
            "fnStateSave": function (oSettings, oData) {
                localStorage.setItem('DataTables_' + window.location.pathname, JSON.stringify(oData));
            },
            "fnStateLoad": function (oSettings) {
                return JSON.parse(localStorage.getItem('DataTables_' + window.location.pathname));
            },
//            "fnStateSaveParams": function (oSettings, oData) {
//              oData.oSearch.sSearch = "";
//            },
            "fnFooterCallback": function (nRow, aaData, iStart, iEnd, aiDisplay) {
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
        });
    }
});



// PARTIE POUR LE FORMULAIRE
//
//
//  des fonctions $f_empty et $f_two_decimals sont définies dans application.js
//
// .decimal (toujours dans application js) permet de gérer l'entrée et la sortie des
// champs de classe décimal
//
//
//
//
//
// gère l'affichage des champs banque et caisse
function $f_td_bank_cash() {
    var income_outcome, payment_mode, caisses, banques, encaissement;
    if ($('.income_book#entry_lines').length > 0) {
        income_outcome = true;
        encaissement = $('optgroup[label="Chèques à l\'encaissement"] option');
    } else {
        income_outcome = false;
    }

    payment_mode = $('#entry_lines #line_payment_mode').val();
    caisses = $('optgroup[label="Caisses"] option');
    banques =  $('optgroup[label="Banques"] option');
    // s'il y a plus d'un élément dans td_bank et si le mode de payemnt est autre que Espèces alors afficher td_bank et masquer td_cash

    switch (payment_mode) {
    case 'Espèces':
        banques.attr('disabled', 'disabled');
        $('#td_check_number').hide();
        caisses.attr('disabled', false);
        banques.attr('selected', false);
        if (income_outcome) {
            encaissement.attr('selected', false);
            encaissement.attr('disabled', 'disabled');
        }
        if (caisses.size() >= 1) {
            caisses.first().attr('selected', 'selected');
        }
        break;
    case 'Chèque':
        caisses.attr('disabled', 'disabled');
        caisses.attr('selected', false);
        if (income_outcome) {
          // on affiche le champ de saisie du numéro de chèque
            $('#td_check_number').hide(); // masquage du champ pour  saisir le n° de chèque de la dépenses
            banques.attr('disabled', 'disabled');
            banques.attr('selected', false);
            encaissement.first().attr('selected', 'selected');
        } else {
            $('#td_check_number').show(); // affichage du champ pour  saisir le n° de chèque de la dépenses
            banques.attr('disabled', false);
            if (banques.size() >= 1) {
                banques.first().attr('selected', 'selected');
            }
        }
        break;
        // autres cas : une recette en banque qui n'est pas un chèque
    default:
        $('#td_check_number').hide(); // masquage du champ pour  saisir le n° de chèque de la dépenses
        caisses.attr('disabled', 'disabled'); // désactivation des caisses
        caisses.attr('selected', false);
        banques.attr('disabled', false);
        if (banques.size() >= 1) {
            banques.first().attr('selected', 'selected');
        }
        if (income_outcome) {
            encaissement.attr('selected', false);
            encaissement.attr('disabled', 'disabled');
        }
    }
}

// gère l'affichage des champs de saisie de banque et de caisse
// à l'affichage de la page
// on doit avoir pour les recettes :
// lorsque c'est espèces les caisses et rien d'autres
// chèques : le compte chèque à l'encaissement
// banques : les banques
// POur les dépenses, la partie chèque à l'encaissement n'est pas utile'
jQuery(function () {
    if ($('#entry_lines').length !== null) {
        $f_td_bank_cash();
    }
    $('#entry_lines #line_payment_mode').live('change', $f_td_bank_cash);
});





