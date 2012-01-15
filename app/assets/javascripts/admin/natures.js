
// fonction permettant de selectionner les classes 6 ou 7 selon le type de nature choisi
//
//
// fonction qui permet de déselctionner les classe 6
//
// 
//function toggle_classe(classe, aff){
//    // on trouve les id des options du select account
//    var myregexp = new RegExp('\^'+classe);
//    jQuery.each($('#natures account_ids option'), function(index, val){
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
////
function change_radio(){

 var rec= $('#nature_income_outcome_true');
 var dep = $('#nature_income_outcome_false');
    if ((dep.attr("checked")!=undefined) && (dep.attr("checked")=='checked')) {
        $('optgroup[label=Dépenses] option').attr('disabled', false);
        $('optgroup[label=Recettes] option').attr('disabled', true);
        }
    if ((rec.attr("checked")!=undefined) && (rec.attr("checked")=='checked')) {
        $('optgroup[label=Recettes] option').attr('disabled', false);
        $('optgroup[label=Dépenses] option').attr('disabled', true);}

}
//
//
//
jQuery(function() {
change_radio();
$('.natures form [type=radio]').click(function() {
    
    change_radio();
});
});
