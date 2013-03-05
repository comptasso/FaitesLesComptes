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

// série de fonction utilisée pour associer un compte aux natures
// un compte de classe 7 ne peut être associé qu'à une nature de type recettes
// de même un compte de classe 6 avev une nature de type dépenses
//
function desac_recettes() {
    $('optgroup[label=Recettes] option').attr('disabled', 'disabled');
}

function desac_depenses() {
    $('optgroup[label=Dépenses] option').attr('disabled', 'disabled');
}
function active_recettes() {
    $('optgroup[label=Recettes] option').attr('disabled', false);
}

function active_depenses() {
    $('optgroup[label=Dépenses] option').attr('disabled', false);
}

function toggle_recettes_depenses(acc) {
    active_depenses();
    active_recettes();
    if (acc.match(new RegExp('^' + '6'))) {
        desac_recettes();
    }
    if (acc.match(new RegExp('^' + '7'))) {
        desac_depenses();
    }

}


jQuery(function () {
    var acc;
    if ($('.accounts input#account_number').length !== 0) {
        acc = $('input#account_number').val();
        toggle_recettes_depenses(acc);
        $('input#account_number').change(function () {
            toggle_recettes_depenses($('input#account_number').val());
        });
    }
});


// série de fonction pour associer par drag and drop les natures et les comptes
//
// Création des accordéon
$(function () {
    var classe;
    $("#accordion").accordion({
        autoHeight: false,
        collapsible: true
    });
});

// Marquage des différentes classes comme étant draggable
$(function () {
    $('.orphan_natures_depenses .nature_depenses, .orphan_natures_recettes .nature_recettes').draggable({
        revert: "invalid",
        cursor: "move",
        helper: "clone"
    });

// les zones de comptes acceptents les natures orphelines correspondantes
// Lors du drop, le style est changé et révèle le lien caché avec l'icone
// qui permet de faire le unlink.
//
// Il y a deux zones de drop : account_list_6 et account_list_7

    $('.account_list_6').droppable({
        accept: ".nature_depenses",
        over: function () {
            $(this).removeClass('out').addClass('over');
        },
        out: function () {
            $(this).removeClass('over').addClass('out');
        },
        drop: function (event, ui) {
            var naturid, accountid;
            $(this).removeClass('over').addClass('out');
            // faire la requete ajax
            ui.draggable.appendTo($(this).find('ul'));
          //  $('#log').text($(this).find('ul').text)
            naturid = ui.draggable.attr('id').match(/\d*$/);
            accountid = $(this).attr('id').match(/\d*$/);
            //   alert("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/link_nature?account_id="+accountid);
            //      $.post("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/link_nature?account_id="+accountid) ;
            $.post("/admin/periods/" + $('#period').text() + "/natures/" + naturid + "/link_nature", "account_id=" + accountid);
        // return false;
        }
    });

    $('.account_list_7').droppable({
        accept: ".nature_recettes",
        over: function () {
            $(this).removeClass('out').addClass('over');
        },
        out: function () {
            $(this).removeClass('over').addClass('out');
        },
        drop: function (event, ui) {
            var naturid, accountid;
            $(this).removeClass('over').addClass('out');
            // on rajoute la nature à la liste sur laquelle elle a été lachée
            ui.draggable.appendTo($(this).find('ul'));
            // faire la requete ajax
            naturid = ui.draggable.attr('id').match(/\d*$/);
            accountid = $(this).attr('id').match(/\d*$/);
            //   alert("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/link_nature?account_id="+accountid);
            $.post("/admin/periods/" + $('#period').text() + "/natures/" + naturid + "/link_nature", "account_id=" + accountid);
        // return false;
        }
    });
  });

