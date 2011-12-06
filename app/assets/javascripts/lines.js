
//
//// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery(function (){
    $('.decimal').live('focus', $f_empty); //vide le champ s'il est à zero (pour faciliter la saisie)
    $('.decimal').live('blur',$f_zero); // met zero dans le champ s'il est vide
});


// fonction permettant de cliquer sur l'id new_line_link avec la combinaison
// de touches Ctrl+N
$(document).keyup(function (e) {
    if(e.which == 17) isCtrl=false;
}).keydown(function(e) {
    if(e.which == 17) isCtrl=true;
    if(e.which == 78 && isCtrl == true) {
        e.stopPropagation();
        $('#new_line_link').click();
        return false;
    }
});

// fonction pour transformer une chaine en float
function stringToFloat(data){
   var d= 0.0;
   if (data != '')
     d=data.replace(/,/, '.' );
    return (parseFloat(d));
}

//  function total_amount(plusieurs){
//    var $total=0.00;
//      $(plusieurs).each(function() {
//         var q=parseFloat(this.value,10);
//         $total += q;
//      });
//      return $total;
//}



// mise en forme des table
$(document).ready(function() {
    $('.data_table').dataTable({

        "oLanguage": {
            "sUrl": "/frenchdatatable.txt"
        },

        "fnFooterCallback": function ( nRow, aaData, iStart, iEnd, aiDisplay ) {
            /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */
            var iTotalDebit = 0;
            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalDebit += stringToFloat(aaData[i][4]*1);
            }

            /* Calculate the market share for browsers on this page */
            var iPageDebit = 0.0
            for ( var i=iStart ; i<iEnd ; i++ )
            {
                iPageDebit += stringToFloat(aaData[aiDisplay[i] ][4]);
            }

            var iTotalCredit = 0.0
            for ( var i=0 ; i<aaData.length ; i++ )
            {
                iTotalCredit += stringToFloat(aaData[i][5]);
            }

            /* Calculate the market share for browsers on this page */
            var iPageCredit = 0.0;
            for ( var i=iStart ; i<iEnd ; i++ )
            {
                iPageCredit += stringToFloat(aaData[ aiDisplay[i] ][5]);
            }

            /* Modify the footer row to match what we want */
            var nCells = nRow.getElementsByTagName('th');
            nCells[1].innerHTML =  iPageDebit.toFixed(2);
            nCells[2].innerHTML =  iPageCredit.toFixed(2);
//            var nGlobals = nRow.getElementsByTagName('tr#global th');
//            nGlobals[1].innerHTML =  iTotalDebit;
//            nGlobals[2].innerHTML =  iTotalCredit;
//             var nSolds = nRow.getElementsByTagName('tr#solds th');
//            nSolds[1].innerHTML =  'bonjour';
//            nSolds[2].innerHTML =  'Bonsoir';
            
        }

    });
});
 

 

// série de fonction qui prépare les champs débit et crédit pour la saisie
// quand on entre dans un champ qui est à 0, on le vide
function $f_empty(){
    if (this.value == '0.00') {
        this.value='';
    }
//   $('#mise_au_point').text('message :dans empty');
//return false;
}
// quand on le quitte et qu'il est vide, on le met à zero'
function $f_zero(){
    if (this.value=='') {
        this.value='0.00';
    }
// return false; jQuery dit qu'il faut retourner false mais alors on perd l'affichage du curseur
}


$.facebox.settings.closeImage = '/assets/closelabel.png';
$.facebox.settings.loadingImage = '/assets/loading.gif';


//
//function pausecomp(ms) {
//ms += new Date().getTime();
//while (new Date() < ms){}
//}




jQuery(document).ready(function($) {
    $('a[rel*=facebox]').facebox();
})

$(document).ready(function() {
    $(document).bind('reveal.facebox', function() {
        $('#new_line').submit(function() {
            $.post(this.action, $(this).serialize(), null, "script");
            return false;
        });
    });
});

