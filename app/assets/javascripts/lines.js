
//
//// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery(function (){
    $('.decimal').live('focus', $f_empty); //vide le champ s'il est à zero (pour faciliter la saisie)
    $('.decimal').live('blur',$f_zero); // met zero dans le champ s'il est vide
});


// fonction permettant de cliquer sur l'id new_line_link avec la combinaison
// de touches Ctrl+N
$(document).keyup(function (e) {
    if(e.which == 17) isCtrl=false;
}).keydown(function(e) {
    if(e.which == 17) isCtrl=true;
    if(e.which == 78 && isCtrl == true) {
        e.stopPropagation();
        $('#new_line_link').click();
        return false;
    }
});



// mise en forme des table
$(document).ready(function() {
    $('.data_table').dataTable({

        "oLanguage": {
                "sUrl": "/frenchdatatable.txt"
            }
//        "oLanguage": {
//            "sLengthMenu": "Affiche _MENU_ lignes par page",
//            "sZeroRecords": "Aucune ligne",
//            "sInfo": "Affichage de  _START_ à _END_ sur _TOTAL_ lignes",
//            "sInfoEmpty": "Affiche de 0 à 0 sur 0 lignes",
//            "sInfoFiltered": "(filtré à partir de _MAX_ lignes)"
//        }
    });
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


$.facebox.settings.closeImage = '/assets/closelabel.png';
$.facebox.settings.loadingImage = '/assets/loading.gif';


//
//function pausecomp(ms) {
//ms += new Date().getTime();
//while (new Date() < ms){}
//}




jQuery(document).ready(function($) {
    $('a[rel*=facebox]').facebox();
})

$(document).ready(function() {
    $(document).bind('reveal.facebox', function() {
        $('#new_line').submit(function() {
            $.post(this.action, $(this).serialize(), null, "script");
            return false;
        });
    });
});

