//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

 jQuery(function (){
    $('.decimal').live('focus', $f_empty); //vide le champ s'il est à zero (pour faciliter la saisie)
    $('.decimal').live('blur',$f_zero); // met zero dans le champ s'il est vide
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
