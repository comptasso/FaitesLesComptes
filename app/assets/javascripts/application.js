// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

 // fonction permettant de modifier un attribut booléen
 // le script retourné par la fonction est alors utilisé pour remplacer le lien.
 // utilisé notamment dans le verrouillage des écritures


 $(document).ready(function (){
  $('a[id ^=lock_open]').click(function(){
   $.post($(this).attr('href'), null,null,"script") ;
   return false;
  });
   });

// jQuery(function (){
//    $('.decimal').live('focus', $f_empty); //vide le champ s'il est à zero (pour faciliter la saisie)
//    $('.decimal').live('blur',$f_zero); // met zero dans le champ s'il est vide
//  });
//
//   // série de fonction qui prépare les champs débit et crédit pour la saisie
//// quand on entre dans un champ qui est à 0, on le vide
//   function $f_empty(){
//    if (this.value == '0.00') {
//        this.value='';
//    }
// //   $('#mise_au_point').text('message :dans empty');
//    //return false;
// }
//// quand on le quitte et qu'il est vide, on le met à zero'
//function $f_zero(){
//     if (this.value=='') {
//         this.value='0.00';
//     }
//     // return false; jQuery dit qu'il faut retourner false mais alors on perd l'affichage du curseur
// }