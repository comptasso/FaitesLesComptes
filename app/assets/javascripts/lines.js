
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


// série de fonction qui prépare les champs débit et crédit pour la saisie
// quand on entre dans un champ qui est à 0, on le vide
function $f_empty() {
    if (this.value === '0.00') {
        this.value = '';
    }
}
// quand on le quitte et qu'il est vide, on le met à zero'
function $f_zero() {
    if (this.value === '') {
        this.value = '0.00';
    }
// return false; jQuery dit qu'il faut retourner false mais alors on perd l'affichage du curseur
}

jQuery(function () {
    $('.decimal').live('focus', $f_empty); //vide le champ s'il est à zero (pour faciliter la saisie)
    $('.decimal').live('blur', $f_zero); // met zero dans le champ s'il est vide
});


// gère l'affichage des champs banque et caisse
function $f_td_bank_cash() {
    var payment_mode = $('#entry_lines #line_payment_mode').val();

    // s'il y a plus d'un élément dans td_bank et si le mode de payemnt est autre que Espèces alors afficher td_bank et masquer td_cash
    if (payment_mode  !== 'Espèces') {
        $('#td_cash').hide();

        //cas d'une dépense payée par chèque'
        if ((payment_mode === 'Chèque') && ($('.outcome_book').length > 0)) {
            // on affiche le champ de saisie du numéro de chèque
            $('#td_check_number').show();
        } else {
            $('#td_check_number').hide();
        }
        // si plusieurs banques on affiche le select
        if ((payment_mode !== "") && $('#line_bank_account_id option').size() > 1) {
            $('#td_bank').show();
        } else {
            $('#td_bank').hide();
        }
    } else {
    // si le mode de paiement est espèces et qu'il y a plus d'une caisse alors afficher les caisses'
        $('#td_bank').hide();
        $('#td_check_number').hide();
        if ($('#line_cash_id option').size() > 1) {
            $('#td_cash').show();
        }
    }
}

// gère l'affichage des champs de saisie de banque et de caisse
// à l'affichage de la page
jQuery(function () {
    if ($('#entry_lines').length !== null) {
        $f_td_bank_cash();
    }
    $('#entry_lines #line_payment_mode').live('change', $f_td_bank_cash);
});


//$.facebox.settings.closeImage = '/assets/closelabel.png';
//$.facebox.settings.loadingImage = '/assets/loading.gif';



