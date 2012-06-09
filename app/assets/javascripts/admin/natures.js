"use strict";
/*jslint browser: true */
var $, jQuery;

function change_radio() {
    var rec = $('#nature_income_outcome_recettes'),
        dep = $('#nature_income_outcome_depenses');
    if (dep.attr("checked") === 'checked') {
        $('optgroup[label=Dépenses] option').attr('disabled', false);
        $('optgroup[label=Recettes] option').attr('disabled', true);
    }
    if (rec.attr("checked") === 'checked') {
        $('optgroup[label=Recettes] option').attr('disabled', false);
        $('optgroup[label=Dépenses] option').attr('disabled', true);
    }
}
//
//
//
jQuery(function () {
    $('.admin_natures optgroup[label=Dépenses] option').attr('disabled', true);
    $('.admin_natures optgroup[label=Recettes] option').attr('disabled', true);
    change_radio();
    $('.admin_natures form [type=radio]').click(function () {
        change_radio();
    });
});
