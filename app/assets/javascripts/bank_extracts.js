//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

"use strict";
/*global $, jQuery */

//var $, jQuery;

function $compute() {
    var sold = 0.0,
        montant = 0.0;
    sold = parseFloat($('#bank_extract_begin_sold').val(), 10) + parseFloat($('#bank_extract_total_credit').val(), 10)
        - parseFloat($('#bank_extract_total_debit').val());
    $('.public_bank_extracts #bank_extract_end_sold').val(sold.toFixed(2));
    // mise à deux décimales du montant saisi
    montant = parseFloat($('#bank_extract_total_credit').val(), 10);
    $('.public_bank_extracts #bank_extract_total_credit').val(montant.toFixed(2));
    montant = parseFloat($('#bank_extract_total_debit').val(), 10);
    $('.public_bank_extracts #bank_extract_total_debit').val(montant.toFixed(2));
    montant = parseFloat($('#bank_extract_begin_sold').val(), 10);
    $('.public_bank_extracts #bank_extract_begin_sold').val(montant.toFixed(2));
}

// les 3 champs de saisie ont la classe décimale
jQuery(function () {
    $('body.public_bank_extracts form').on('change','input.decimal', $compute); // calcule le nouvau solde et l'affiche
});



