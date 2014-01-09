"use strict";
/*jslint browser: true */
/*global $, jQuery */

//var $, jQuery;

// function utilisée pour disable ou able les différentes parties
// du select 
function change_radio() {
    var sel = $('select#nature_book_id option').filter(':selected');
        
    if (sel.attr("data-type") === 'OutcomeBook') {
        $('optgroup[label=Dépenses] option').attr('disabled', false);
        $('optgroup[label=Recettes] option').attr('disabled', true);
    }
    if (sel.attr("data-type") === 'IncomeBook') {
        $('optgroup[label=Recettes] option').attr('disabled', false);
        $('optgroup[label=Dépenses] option').attr('disabled', true);
    }
}
//
// Le but est ici de garder dynamiquement la cohérence dans le formulaire
// de création de nature entre le type de nature (recette ou dépenses)
// et le compte auquel elle peut être rattachée.
//
jQuery(function () {
    $('.admin_natures optgroup[label=Dépenses] option').attr('disabled', true);
    $('.admin_natures optgroup[label=Recettes] option').attr('disabled', true);
    change_radio();
    $('.admin_natures select#nature_book_id').change(function () {
        change_radio();
    });
});


// pour permettre le classement des natures dans la vue index par un drag & drop 
// Si la table #index dans le body de classe admin_natures existe, 
// alors on appelle fnTableSortable qui est défini dans application.js
// fonction qui appelle l'action reorder du controller - ici admin/natures_controller/reorder
jQuery(function() {
  if ($('.admin_natures #index').length === 1) {
    fnTableSortable($('.admin_natures #recettes'), '/reorder');
    fnTableSortable($('.admin_natures #depenses'), '/reorder');
  }
})