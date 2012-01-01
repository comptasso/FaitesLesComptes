
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
//var isCtrl=false;
//$(document).keyup(function (e) { if (e.which == 17) isCtrl=false;});
//$(document).keydown(function(e) {
//    if (e.which == 17) isCtrl=true;
//    if (e.which == 78 && isCtrl == true) {
//        e.stopPropagation();
//
//        $('#new_line_link').click();
//        return false;
//    }
//});


// mise en forme des tables de lignes
jQuery(function() {
    if ($('.lines .data_table').length != 0) {
        var oTable= $('.lines .data_table').dataTable(
        {
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
                    iTotalDebit += stringToFloat(aaData[i][4]);
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
                nCells[1].innerHTML =  iPageDebit.toFixed(2) +'<br/>'+ iTotalDebit.toFixed(2);
                nCells[2].innerHTML =  iPageCredit.toFixed(2)+'<br/>'+ iTotalCredit.toFixed(2);
          
            }

        });


        $('td', oTable.fnGetNodes()).hover( function() {
            var iCol = $('td', this.parentNode).index(this) % 6;
            var nTrs = oTable.fnGetNodes();
            $('td:nth-child('+(iCol+1)+')', nTrs).addClass( 'highlighted' );
        }, function() {
            $('td.highlighted', oTable.fnGetNodes()).removeClass('highlighted');
        } );
    }
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

// masque les champs de saisie de banque et de caisse s'il n'y a qu'un seul élément dans la liste'
jQuery(function(){
    // if ($('#line_bank_account_id option').size() <= 1 ) {
    $('#td_bank').hide() ; 
    // }
    //   if ($('#line_cash_id option').size() <= 1 ) {
    $('#td_cash').hide() ; 
//  }
 
});

jQuery(function (){
    $('#line_payment_mode').live('change', $f_td_bank_cash); //gère les conséquence du choix du mode de paiement
});

//
function $f_td_bank_cash(){

    // s'il y a plus d'un élément dans td_bank et si le mode de payemnt est autre que Espèces alors afficher td_bank et masquer td_cash
    if ( ($('#line_payment_mode').val() != 'Espèces'))
    {
        $('#td_cash').hide();
        if  ($('#line_bank_account_id option').size() > 1)
        {
            $('#td_bank').show();
        }
    }
    
    // si le mode de paiement est espèces et qu'il y a plus d'une caisse alors afficher les caisses'
    if (($('#line_payment_mode').val() == 'Espèces'))
    {
        $('#td_bank').hide();
        if  ($('#line_cash_id option').size() > 1)
        {
            $('#td_cash').show();
        }
    }
}


$.facebox.settings.closeImage = '/assets/closelabel.png';
$.facebox.settings.loadingImage = '/assets/loading.gif';

//$(document).ready(function() {
//    $('#new_line_link').facebox();
//    $(document).bind('reveal.facebox', function() {
//        $('#new_line').submit(function() {
//            $.post(this.action, $(this).serialize(), null, "script");
//            return false;
//        });
//        $('.input_date').datepicker(
//        {
//            dateFormat: 'dd/mm/yy',
//            buttonImage: '/assets/cal.gif',
//            buttonImageOnly: true,
//            showOn: 'both',
//            minDate: $('.input_date').attr('data-jcmin'),
//            maxDate: $('.input_date').attr('data-jcmax')
//        }
//        );
//    });
//});


