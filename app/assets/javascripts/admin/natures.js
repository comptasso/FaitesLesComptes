/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

// fonction permettant de selectionner les classes 6 ou 7 selon le type de nature choisi
//
//
// fonction qui permet de déselctionner les classe 6
//
// 
//function toggle_classe(classe, aff){
//    // on trouve les id des options du select account
//    var myregexp = new RegExp('\^'+classe);
//    jQuery.each($('#nature_account_ids option'), function(index, val){
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
//function change_radio(){
// //   _test2.attr("checked") != "undefined" && _test2.attr("checked") == "checked");
// var rec= $('#nature_income_outcome_true');
// var dep = $('#nature_income_outcome_false');
//    if ((dep.attr("checked")!=undefined) && (dep.attr("checked")=='checked')) {toggle_classe('7',false); toggle_classe('6', true);}
//    if ((rec.attr("checked")!=undefined) && (rec.attr("checked")=='checked')) {toggle_classe('7',true); toggle_classe('6', false);}
//
//}
//
//
//
//jQuery(function() {
//
//change_radio();
//$('[type=radio]').click(function() {
//    change_radio();
//});
