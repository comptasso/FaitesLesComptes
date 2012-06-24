//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

"use strict";

var $, jQuery;

function $compute() {
    var sold = 0.0;
    sold = parseFloat($('#bank_extract_begin_sold').val(), 10) + parseFloat($('#bank_extract_total_credit').val(), 10)
        - parseFloat($('#bank_extract_total_debit').val());
    $('.public_bank_extracts #bank_extract_end_sold').val(sold.toFixed(2));
}

// les 3 champs de saisie ont la classe décimale
jQuery(function () {
    $('input.decimal').live('change', $compute); // calcule le nouvau solde et l'affiche
});

//jQuery(function () {
//    // on associe le clic sur le bouton vers la gauche au
//    //   clic sur le bouton du formulaire qui est à droite
//
//    $('#left_arrow').click(function () {
//        $('input[value=Déplace]').click();
//    });
//    // et on cache le bouton d'origine
//    $('input[value=Déplace]').hide();
//    // même chose avec le chevron vers la droite
//    $('#right_arrow').click(function () {
//        $('input[value=Renvoie]').click();
//    });
//    $('input[value=Renvoie]').hide();
//    $('#left_arrow').css('cursor', 'default');
//    $('#right_arrow').css('cursor', 'default');
//
//    // faire en sorte que le bouton soit changé quand il y a des éléments sélectionnés
//    // récupérer les éléments cochés
//    $('#to_point input').live('change', function () {
//        if ($('#to_point input:checked').length > 0) {
//            $('#left_arrow img').attr('src', '/assets/BlurMetalLb6.gif');
//            $('#left_arrow').css('cursor', 'pointer');
//        } else {
//            $('#left_arrow img').attr('src', '/assets/BlurMetalLi6.gif');
//            $('#left_arrow').css('cursor', 'default');
//        }
//    });
//    $('#extract input').live('change', function () {
//        if ($('#extract input:checked').length > 0) {
//            $('#right_arrow img').attr('src', '/assets/BlurMetalLc6.gif');
//            $('#right_arrow').css('cursor', 'pointer');
//        } else {
//            $('#right_arrow img').attr('src', '/assets/BlurMetalLj6.gif');
//            $('#right_arrow').css('cursor', 'default');
//        }
//    });
//
//});


