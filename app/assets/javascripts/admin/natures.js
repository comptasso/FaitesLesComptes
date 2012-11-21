"use strict";
/*jslint browser: true */
var $, jQuery;



// function utilisée pour disable ou able les différentes parties
// du select 
function change_radio() {
    var rec = $('#nature_income_outcome_true'),
        dep = $('#nature_income_outcome_false');
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
// Le but est ici de garder dynamiquement la cohérence dans le formulaire
// de création de nature entre le type de nature (recette ou dépenses)
// et le compte auquel elle peut être rattachée.
//
jQuery(function () {
    $('.admin_natures optgroup[label=Dépenses] option').attr('disabled', true);
    $('.admin_natures optgroup[label=Recettes] option').attr('disabled', true);
    change_radio();
    $('.admin_natures form [type=radio]').click(function () {
        change_radio();
    });
});

function fnTableSortable(table) {
  $(table).sortable({
    connectWith: table.val('id'),
    items: "tr",
    //callback utilisée pour le changement d'emplacement à l'intérieur de la table
    // des natures.
    update: function(event, ui) {

      var tbody = table;
      var id = ui.item.context.id;
      // les id des lignes sont constituées uniquement de l'id de la Nature

        // la logique est la suivante : data-position donne la position initiale de la ligne
        // après un déplacement data-position est du coup le numéro de ligne d'origine
        var from = $("#" + id).attr('data-position');
        // il faut donc trouver à quelle place se trouve le drop
        // chercher quel est le rang en balayant les lignes
        var to = -1;
        table.find('tr').each(function(index){
          if ($(this).attr('id') == parseInt(id)) {
            to = index;
          }

        });

        $.ajax({
          // l'action actuelle mais avec reorder
          url: window.location.pathname + '/reorder',
          type: 'post',
          data: {
            id: id,
            fromPosition: from,
            toPosition: to
          },
          // puis on fait la mise à jour des données de la table
          success: function () {
            fnMoveRows(tbody, from, to);
          },
          // ou inversement on annule si erreur
          error: function (jqXHR) {
            fnCancelSorting(tbody, jqXHR.statusText);
          }
        });

    }
})
}


jQuery(function() {
  if ($('.admin_natures #index').length === 1) {

    fnTableSortable($('.admin_natures #recettes'));
    fnTableSortable($('.admin_natures #depenses'));
 

  

  $('.admin_natures #depenses').sortable({
    connectWith: "#depenses",
    items: "tr",
    //callback utilisée pour le changement d'emplacement à l'intérieur de la table
    // des natures.
    update: function(event, ui) {

      var tbody = $('#depenses');
      var id = ui.item.context.id;
      // les id des lignes sont constituées uniquement de l'id de la Nature

        // la logique est la suivante : data-position donne la position initiale de la ligne
        // après un déplacement data-position est du coup le numéro de ligne d'origine
        var from = $("#" + id).attr('data-position');
        // il faut donc trouver à quelle place se trouve le drop
        // chercher quel est le rang en balayant les lignes
        var to = -1;
        $('#depenses tr').each(function(index){
          if ($(this).attr('id') == parseInt(id)) {
            to = index;
          }

        });

        $.ajax({
          // l'action actuelle mais avec reorder
          url: window.location.pathname + '/reorder',
          type: 'post',
          data: {
            id: id,
            fromPosition: from,
            toPosition: to
          },
          // puis on fait la mise à jour des données de la table
          success: function () {
            fnMoveRows(tbody, from, to);
          },
          // ou inversement on annule si erreur
          error: function (jqXHR) {
            fnCancelSorting(tbody, jqXHR.statusText);
          }
        });

    }
  });
  }
})