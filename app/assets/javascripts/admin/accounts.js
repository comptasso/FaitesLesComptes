// mise en forme des tables de lignes
jQuery(function() {
    if ($('.accounts .data_table').length != 0) {
        var oTable= $('.accounts .data_table').dataTable(
        {
            "oLanguage": {
                "sUrl": "/frenchdatatable.txt"
            },
 "aoColumns": [
            { "sType": "string" },
            null,
            null,
           {"bSortable": false}
            ]

        });
        
        var nCells=$('tbody tr:nth-child(1) td').length;
        $('td', oTable.fnGetNodes()).hover( function() {

            var iCol = $('td', this.parentNode).index(this) % nCells;
            var nTrs = oTable.fnGetNodes();
            $('td:nth-child('+(iCol+1)+')', nTrs).addClass( 'highlighted' );
        }, function() {
            $('td.highlighted', oTable.fnGetNodes()).removeClass('highlighted');
        } );
    }
});

// fonction permettant de selectionner les classes 6 ou 7 selon le type de nature choisi
//
//
// fonction qui permet de déselctionner les classe 6
//function toggle_classe(classe, aff){
//    // on trouve les id des options du select account
//    var myregexp = new RegExp('\^'+classe);
//    jQuery.each($('#account_nature_ids option'), function(index, val){
//         if ($(val).text().match(myregexp)) {
//             if (aff==false) {
//                 $(val).attr('disabled', 'disabled');
//             }
//              if (aff==true) {
//                  $(val).attr('disabled', false);
//              }
//         }
//    });
//}
//
//function change_classe(){
// //   _test2.attr("checked") != "undefined" && _test2.attr("checked") == "checked");
// var rec_dep= $('#account_number').val();
//  
// var dep = $('#nature_income_outcome_false');
//    if (rec_dep.match(myregexp)) {toggle_classe('7',false); toggle_classe('6', true);}
//    if (!rec_dep.match(myregexp)) {toggle_classe('7',true); toggle_classe('6', false);}
//
//
//}



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
		$( "#accordion" ).accordion();
	});

$(function() {
   $('.nature').draggable({
       revert: "invalid",
       cursor: "move",
       helper: "clone"
   });
   $('.account_list').droppable({
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
          var naturid=ui.draggable.attr('id').match(/\d*$/);
          var accountid=$(this).attr('id').match(/\d*$/);
        //   alert("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/link_nature?account_id="+accountid);
          $.post("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/link_nature?account_id="+accountid) ;
      // return false;
      }
   });

   $('.mapping_natures').droppable({
       over: function() {
          $(this).removeClass('out').addClass('over');
      },
      out: function() {
          $(this).removeClass('over').addClass('out');
      },
      drop: function(event, ui) {
         // $(this).find(".")
          $(this).removeClass('over').addClass('out');
           // faire la requete ajax l' élément à la liste '
          ui.draggable.appendTo($(this).find('ul'));
          var naturid=ui.draggable.attr('id').match(/\d*$/);
    //       alert("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/unlink_nature");
          $.post("/admin/periods/"+$('#period').text()+"/natures/"+naturid+"/unlink_nature") ;
   }
   });
});