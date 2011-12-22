//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

// les 3 champs de saisie ont la classe décimale
 jQuery(function (){
    $('input.decimal').live('change',$compute); // calcule le nouvau solde et l'affiche
  });

 function $compute(){
     var sold= 0.0;
   sold= parseFloat($('#bank_extract_begin_sold').val(),10) + parseFloat($('#bank_extract_total_credit').val(),10)
       -parseFloat($('#bank_extract_total_debit').val());
    // sold= 'bonjour'; // $('.banck_extract #bank_extract_begin_sold').val(); // +  - $('.banck_extract #bank_extract_total_debit').value;
     $('.bank_extracts #span_end_sold').text(sold.toFixed(2));
     //$('.bank_extracts input#bank_extract_begin_sold').color('red');
 }

jQuery(function(){
    // on rend le chevron verrs la gauche cliquable
 //   $('#left_arrow').addClass('cliquable').css('a:hover', cur);
    $('#left_arrow').click(function(){
        $('input[value=Déplace]').click();
    });
    // et on cache le bouton d'origine
    $('input[value=Déplace]').hide();
    // même chose avec le chevron vers la droite
    $('#right_arrow').click(function(){
        $('input[value=Renvoie]').click();
    });
    $('input[value=Renvoie]').hide();
})


