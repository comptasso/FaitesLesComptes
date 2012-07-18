"use strict";
/*jslint browser: true */
var jQuery, $;

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
            "iDisplayLength": 15,
            "aLengthMenu": [[15, 25, 50, -1], [15, 25, 50, "Tous"]]
        }
    );
});


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



jQuery(function() {
    if ($('.accounts input#account_number').length != 0) {
        var acc= $('input#account_number').val();
        toggle_recettes_depenses(acc);
        $('input#account_number').change(function(){
            toggle_recettes_depenses($('input#account_number').val());
        });
    }
});

function toggle_recettes_depenses(acc) {
    active_depenses();
    active_recettes();
    if (acc.match(new RegExp('\^'+ '6'))) {
        desac_recettes();
  
    }

    if (acc.match(new RegExp('\^'+ '7'))) {
  
        desac_depenses();
    }

}


//$(document).ajaxSend(function(e, xhr, options) {
//  var token = $("meta[name='csrf-token']").attr("content");
//  xhr.setRequestHeader("X-CSRF-Token", token);
//});

$(function() {
    var classe;
    $( "#accordion" ).accordion({
        autoHeight: false,
        collapsible: true
    });


 
});

$(function() {
    $('.orphan_natures_depenses .nature_depenses, .orphan_natures_recettes .nature_recettes').draggable({
        revert: "invalid",
        cursor: "move",
        helper: "clone"
    });

// les zones de comptes acceptents les natures orphelines correspondantes
// Lors du drop, le style est changé et révèle le lien caché avec l'icone
// qui permet de faire le unlink.

    $('.account_list_6').droppable({
        accept: ".nature_depenses",
        over: function() {
            $(this).removeClass('out').addClass('over');
        },
        out: function() {
            $(this).removeClass('over').addClass('out');
        },
        drop: function(event, ui) {
          
            // $(this).find(".")
            $(this).removeClass('over').addClass('out');
            // faire la requete ajax
            ui.draggable.appendTo($(this).find('ul'));
          //  $('#log').text($(this).find('ul').text)
            var naturid = ui.draggable.attr('id').match(/\d*$/);
            var accountid = $(this).attr('id').match(/\d*$/);
            //   alert("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/link_nature?account_id="+accountid);
            //      $.post("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/link_nature?account_id="+accountid) ;
            $.post("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/link_nature", "account_id="+ accountid) ;
        // return false;
        }
    });

    $('.account_list_7').droppable({
        accept: ".nature_recettes",
        over: function() {
            $(this).removeClass('out').addClass('over');
        },
        out: function() {
            $(this).removeClass('over').addClass('out');
        },
        drop: function(event, ui) {

            $('#log').text('drop d un account 7')
            // $(this).find(".")
            $(this).removeClass('over').addClass('out');
            // faire la requete ajax

            ui.draggable.appendTo($(this).find('ul'));
            var naturid = ui.draggable.attr('id').match(/\d*$/);
            var accountid = $(this).attr('id').match(/\d*$/);
            //   alert("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/link_nature?account_id="+accountid);
            $.post("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/link_nature", "account_id="+ accountid) ;
        // return false;
        }
    });


//
//
//    $('.orphan_natures_recettes').droppable({
//        accept: ".nature_recettes",
//        over: function() {
//            $(this).removeClass('out').addClass('over');
//        },
//        out: function() {
//            $(this).removeClass('over').addClass('out');
//        },
//        drop: function(event, ui) {
//            // $(this).find(".")
//            $(this).removeClass('over').addClass('out');
//            // faire la requete ajax l' élément à la liste '
//            ui.draggable.appendTo($(this).find('ul'));
//            var naturid=ui.draggable.attr('id').match(/\d*$/);
//            //       alert("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/unlink_nature");
//            $.post("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/unlink_nature");
//        }
//    });
//
//
//
//    $('.orphan_natures_depenses').droppable({
//        accept: ".nature_depenses",
//        over: function() {
//            $(this).removeClass('out').addClass('over');
//        },
//        out: function() {
//            $(this).removeClass('over').addClass('out');
//        },
//        drop: function(event, ui) {
//            // $(this).find(".")
//            $(this).removeClass('over').addClass('out');
//            // faire la requete ajax l' élément à la liste '
//            ui.draggable.appendTo($(this).find('ul'));
//            var naturid=ui.draggable.attr('id').match(/\d*$/);
//            //       alert("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/unlink_nature");
//            $.post("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/unlink_nature");
//        }
//    });
});

//jQuery(function(){
//    $('.list_accounts .unchain').
//})