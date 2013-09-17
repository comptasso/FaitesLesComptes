///* mise en forme des tables de lignes */
//"use strict";
///*jslint browser: true */
///*global $, jQuery */
//
////var jQuery, $, fnChangeValue, fnCancelSorting;
//
////appelée après avoir enlevé une ligne
//// on retire donc 1 pour chacun des lignes qui se trouvait après celle qu'on a retiré
//function fnDecRows(from) {
//    var iFrom, pos;
//    iFrom = parseInt(from, 10);
//    $('#bels tr').each(function (index) {
//        pos = parseInt($(this).attr('data-position'), 10);
//        if (pos > iFrom) {
//            fnChangeValue($(this), (parseInt(pos, 10) - 1).toString());
//        }
//    });
//}
//
//function fnIncRows(from) {
//    var iFrom, pos;
//    iFrom = parseInt(from, 10);
//    $('#bels tr').each(function (index) {
//        pos = parseInt($(this).attr('data-position'), 10);
//        if (pos >= iFrom) {
//            fnChangeValue($(this), (parseInt(pos, 10) + 1).toString());
//        }
//    });
//}
//
//function fnSum(selector) {
//    var total = 0;
//    $(selector).each(function() {
//        console.log($(this).text());
//        total += stringToFloat($(this).text()) || 0;
//    });
//    return(total);
//
//}
//
//function fnCheckTotalDebit() {
//    if ($('#bels_total_debit').text() === $('#total_debit').text()) {
//        $('#img_danger_total_debit').hide();
//    } else {
//        $('#img_danger_total_debit').show();
//    }
//}
//
//function fnCheckTotalCredit() {
//    if ($('#bels_total_credit').text() === $('#total_credit').text()) {
//        $('#img_danger_total_credit').hide();
//    } else {
//        $('#img_danger_total_credit').show();
//    }
//}
//
//jQuery(function () {
//  
//    $('#bels_total_credit').text(fnSum('#bels td.credit'));
//    $('#bels_total_debit').text(fnSum('#bels td.debit'));
//
//    if ($('#zone_ltps').length === 1) {
//
//        // AFFICHAGE DES POPOVERS
//        $('img[alt="Detail"]').popover();
//
//        $('#img_danger_total_debit').tooltip();
//        $('#img_danger_total_credit').tooltip();
//
//        // $('#myModal').modal();
//
//        // AFFICHER OU MASQUER LES PANNEAUX DANGER A L AFFICHAGE DE LA PAGE
//        // la mise à jour est faite par le traitement de la réponse du controller
//        // aux actions remove et insert
//        fnCheckTotalDebit();
//        fnCheckTotalCredit();
//
//        var bTable, lTable;
//
//        bTable = $('#bels_table').dataTable({
//            "sScrollY": "400px",
//            "bPaginate": false,
//            "bScrollCollapse": false,
//            "bSort": false,
//            "bFilter": false,
//            'bInfo': false
//        });
//
//        lTable = $('#ltps_table').dataTable({
//            "sScrollY": "400px",
//            "bPaginate": false,
//            "bScrollCollapse": false,
//            "bFilter": false,
//            'bInfo': false,
//            "aaSorting": [[1, 'asc']],
//            "aoColumnDefs": [
//                {   // la première colonne et la colonne action ne sont pas sortable
//                    "bSortable": false,
//                    "aTargets": [ 0, 'actions' ] 
//                },
//                {
//                    "sType": "date-euro",
//                    "asSortable": ['asc', 'desc'],
//                    "aTargets": ['date-euro'] // les colonnes date au format français ont la classe date-euro
//                }
//
//            ]
//        });
//
//        bTable.fnAdjustColumnSizing();
//        lTable.fnAdjustColumnSizing();
//
//        // LA TABLE DES LTPS LINES TO POINT)
//        $('#ltps').sortable({
//            connectWith: ".connectedSortable",
//            items: "tr"
//        });
//
//        // LA TABLE DES BELS
//        $("#bels").sortable({
//            connectWith: ".connectedSortable",
//            items: "tr",
//            //
//            // lorsqu'on ajoute un membre à la table, il faut envoyer une action
//            // insert en indiquant l'id comme params
//            receive: function (event, ui) {
//                var place = -1, id, siblings;
//                id = ui.item.context.id;
//                siblings = $("#" + id + ' ~ tr'); // fonction qui trouve les suivants
//                // #0 est une ligne utilisée pour indiquer qu'on peut faire un drag and drop
//                // si elle est là, la position est forcément la première.
//                if ($('#bels #0').length === 1) {
//                    place = 1;
//                } else if (siblings.length === 0) {
//                    // c'est le dernier de la liste donc on
//                    // prend la longueur de la liste
//                    place = $('#bels tr').length;
//                } else {
//                    // sinon on prend la position du premier suivant
//                    place =  $(siblings[0]).attr('data-position');
//                }
//
//
//                $.ajax({
//                    url: window.location.pathname.replace('pointage', id.toString() + '/insert'),
//                    type: 'post',
//                    data: {
//                        html_id: id,
//                        at: place
//                    },
//                    success: function () {
//
//                    },
//
//                    // ou inversement on annule si erreur
//                    error: function (jqXHR) {
//                        fnCancelSorting(ui.sender, jqXHR.statusText);
//                    }
//                });
//            },
//
//            // lorsqu'on retire un membre de la table, il faut
//            // noter sa position, faire une requête ajax pour le supprimer de
//            // la base de données,
//            // et insérer une réponse dans la table d'arrivée au bon endroit
//            // ou redessiner la table d'arrivée'
//            remove: function (event, ui) {
//
//                // $('h3').text('remove en action');
//                var id, from;
//                id = ui.item.context.id;
//                from = $("#" + id).attr('data-position');
//                $.ajax({
//                    url: window.location.pathname.replace('pointage', id.toString() + '/remove'),
//                    type: 'post',
//                    data: {
//                        id: id
//                    },
//                    success: function () {
//
//                    },
//
//                    // on annule si erreur
//                    error: function (jqXHR) {
//                        fnCancelSorting(ui.sender, jqXHR.statusText);
//                    }
//                });
//            },
//
//            //callback utilisée pour le changement d'emplacement à l'intérieur de la table
//            // des bank_extract_lines. On ne doit pas appeler update pour les
//            // transferts d'une table à l'autre doù la nécessité d'un filtre
//            // basé sur ui.sender
//            update: function (event, ui) {
//                var tbody, id, from, to;
//                tbody = $('#bels');
//                id = ui.item.context.id;
//                // les id des bels sont constituées uniquement de l'id de la BankExtractLine'
//
//                if (ui.sender === null) {
//                    // la logique est la suivante : data-position donne la position initiale de la ligne
//                    // après un déplacement data-position est du coup le numéro de ligne d'origine
//                    from = $("#" + id).attr('data-position');
//                    // il faut donc trouver à quelle place se trouve le drop
//                    // chercher quel est le rang en balayant les lignes
//                    to = -1;
//                    $('#bels tr').each(function (index) {
//                        if ($(this).attr('id') === id) {
//                            to = index + 1;
//                        }
//
//                    });
//
//                    $.ajax({
//                        // il faut remplacer pointage par reorder
//                        url: window.location.pathname.replace('pointage', 'reorder'),
//                        type: 'post',
//                        data: {
//                            id: id,
//                            fromPosition: from,
//                            toPosition: to
//                        },
//                        // puis on fait la mise à jour des données de la table
//                        success: function () {
//
//                        },
//                        // ou inversement on annule si erreur
//                        error: function (jqXHR) {
//                            fnCancelSorting(tbody, jqXHR.statusText);
//                        }
//                    });
//
//                }
//
//            }
//        }).disableSelection();
//
//    }
//});
//
//
//
