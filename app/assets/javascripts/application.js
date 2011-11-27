// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-ui
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

