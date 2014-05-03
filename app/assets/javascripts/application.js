// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-ui
//= require best_in_place
//= require jquery_ujs
//= require jquery.jqplot
//= require_tree .
//
//
//
//


// voir aussi le fichier general.js.coffee qui est un complément 
// à ce fichier mais au format coffee

"use strict";
/*jslint browser: true */
/*global $, jQuery */

// fonction permettant de modifier un attribut booléen
// le script retourné par la fonction est alors utilisé pour remplacer le lien.
// utilisé notamment dans le verrouillage des écritures
$(document).ready(function () {
    $('a[id ^=lock_open]').click(function () {
        $.post($(this).attr('href'), null, null, "script");
        return false;
    });
});

// pour les menus déroulants de bootstrap ?
$('.dropdown-toggle').dropdown();

// activation de best_in_place
$(document).ready(function() {
  /* Activating Best In Place */
  jQuery(".best_in_place").best_in_place();
});




// fonction utilisée pour afficher un date picker pour chaque champ de class
// .input_date_picker. Ces champs imput_date sont créés facilement par une extension de simple_form_form
//
// Date min et
// date max sont transmis par cette fonction sous forme d'attributs  data-jcmin et data-jcmax
jQuery(function () {
    jQuery.each($('.input_date_picker'), function (index, val) {
        $(val).datepicker(
            {
                dateFormat: 'dd/mm/yy',
                minDate: $(val).attr('data-jcmin'),
                maxDate: $(val).attr('data-jcmax')
            }
        );
    });
});

/* French initialisation for the jQuery UI date picker plugin. */
/* Written by Keith Wood (kbwood{at}iinet.com.au) and Stéphane Nahmani (sholby@sholby.net). */
jQuery(function ($) {
    $.datepicker.regional.fr = {
        closeText: 'Fermer',
        prevText: '&#x3c;Préc',
        nextText: 'Suiv&#x3e;',
        currentText: 'Courant',
        monthNames: ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'],
        monthNamesShort: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'],
        dayNames: ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'],
        dayNamesShort: ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'],
        dayNamesMin: ['Di', 'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa'],
        weekHeader: 'Sm',
        dateFormat: 'dd/mm/yy',
        firstDay: 1,
        isRTL: false,
        showMonthAfterYear: false,
        yearSuffix: ''
    };
    $.datepicker.setDefaults($.datepicker.regional.fr);
});


/*les options pour le spinner
 On crée ensuite un spinner suite par exemple à l'action click
de la façon suivante.
  $('#new_balance_button').click(function() {
      var target = document.getElementById('new_compta_balance');
      var spinner = new Spinner(opts).spin(target);
    });
*/
var jc_spinner_opts = {
    lines: 13, // The number of lines to draw
    length: 7, // The length of each line
    width: 4, // The line thickness
    radius: 26, // The radius of the inner circle
    corners: 0.8, // Corner roundness (0..1)
    rotate: 0, // The rotation offset
    color: '#000', // #rgb or #rrggbb
    speed: 1, // Rounds per second
    trail: 60, // Afterglow percentage
    shadow: false, // Whether to render a shadow
    hwaccel: false, // Whether to use hardware acceleration
    className: 'spinner', // The CSS class to assign to the spinner
    zIndex: 2e9, // The z-index (defaults to 2000000000)
    top: '100px', // car auto fait qu'on ne voit pas le spinner si le document affiché est long 
    // il se place au milieu de la zone donc alors invisible.
    left: 'auto' // Left position relative to parent in px
  };
  
var small_spinner_opts = {
    lines: 13, //# The number of lines to draw
    length: 5, // The length of each line
    width: 2, // The line thickness
    radius: 5, // The radius of the inner circle
    corners: 0.8, // Corner roundness (0..1)
    rotate: 0, // The rotation offset
    color: '#000', // #rgb or #rrggbb
    speed: 1, // Rounds per second
    trail: 60, // Afterglow percentage
    shadow: false, // Whether to render a shadow
    hwaccel: false, // Whether to use hardware acceleration
    className: 'spinner', // The CSS class to assign to the spinner
    zIndex: 2e9, // The z-index (defaults to 2000000000)
    // il se place au milieu de la zone donc alors invisible.
    left: '200px' // Left position relative to parent in px
  };
  
  
  

// fonction pour transformer une chaine avec virgule en float
// la fonction retire les espaces et remplace la virgule par le point décimal
// avant d'appeler Number, la fonction native de js.
function stringToFloat(jcdata) {

    if (jcdata === undefined) {
        return 0.0;
    }
    var d = String(jcdata).replace(/,/, '.');
    d = d.replace(/\s/g, '');
    if (isNaN(d)) {
        return 0.0;
    } else {
        return Number(d);
    }
}

// prend un nombre et en fait une chaîne avec deux décimales et 
// une virgule comme séparateur décimal
function $f_numberWithPrecision(number) {
  var part1, part2, parts;
  if (number === undefined) {
        return '-';
    }
    number =  number.toFixed(2); // on garde deux décimales
    if (isNaN(number)) {
      return '-'
    } else {
  parts = String(number).split('.');
  part1 = parts[0];
	part2 = parts.length > 1 ? ',' + parts[1] : '';
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(part1)) {
		part1 = part1.replace(rgx, '$1' + ' ' + '$2');
	}
	return part1 + part2;
    }
}

// fonction permettant de mettre deux décimales à un nombre
// appelé lorsque l'utilisateur sort d'un champ pour remettre en forme sa saisir
// Par exemple 32 devient 32.00 ou 32.5 devient 32.50
function $f_two_decimals() {
    var number = stringToFloat(this.value);
    if (isNaN(number)) {
        this.value = '0.00';
    } else {
        this.value = number.toFixed(2);
    }
}

// série de fonction qui prépare les champs débit et crédit pour la saisie
// quand on entre dans un champ qui est à 0, on le vide
function $f_empty() {
    if (this.value === '0.00') {
        this.value = '';
    }
}


jQuery(function () {
    $('.decimal').live('focus', $f_empty); //vide le champ s'il est à zero (pour faciliter la saisie)
    $('.decimal').live('blur', $f_two_decimals);
   
});

// série de 3 fonctions utilisées pour le tri des tables
// _fnAlert affiche un message si l'opération échoue'
function _fnAlert(message, type) {
    alert(message);
  }


// fnChangeValue met data-position et le premier champ de la ligne de la table
// à la valeur donnéé par new_value
  function fnChangeValue(element, new_value) {
    element.attr('data-position', new_value);
    element.find('td:first-child').text(new_value);
  }

  // appelée par ajax en cas d'erreur
  function fnCancelSorting(tbody, sMessage) {
    tbody.sortable('cancel');
    if(sMessage!= undefined){
      _fnAlert(sMessage, "");
    }else{
      _fnAlert("La ligne n'a pas pu être déplacée", "");
    }
  }

  // fnMoveRows est la fonction appelée après la réponse ok de
  // reorder du controller pour renuméroter l'information de position des lignes
  // en effet, la mise à jour de l'affichage est faite par javascript et non par un
  // render du controller
  function fnMoveRows(tbody, from, to) {
    var iFrom = parseInt(from);
    var iTo = parseInt(to);
    var pos;
    // par exemple, je passe la ligne 2 à la ligne 6,
    if (iTo > iFrom) {
        tbody.find('tr').each(function(index){
        pos = parseInt($(this).attr('data-position'));
        // et la ligne 2 devient la ligne 6
        if (pos == iFrom) {
          fnChangeValue($(this), iTo.toString());
        }
        // les lignes 3 à 6 perdent 1 cran
        if (pos > iFrom && pos <= iTo) {
          fnChangeValue($(this), (pos-1).toString());
        }
      });
    }
    //dans l'autre sens, je passe de la ligne 6 à la ligne 2'
    // donc iFrom = 6 et iTo = 2
    if (iTo < iFrom) {
      tbody.find('tr').each(function(index){
        pos = parseInt($(this).attr('data-position'));
        // et la ligne 6 devient la ligne 2
        if (pos == iFrom) {
          fnChangeValue($(this), iTo.toString());
        }

        // les lignes 2 à 5 gagnent 1 cran
        if (pos >= iTo && pos < iFrom) {
          fnChangeValue($(this), (parseInt(pos)+1).toString());
        }
      });
    }

  }

/* Ces deux fonctions ont pour objet de bloquer la page pour une action de téléchargement de 
 * fichier. 
 * 
 * Il faut modifier le formulaire utilisé pour introduire un champ caché avec l'id
 * 'download_token_value_id'. La fonction crée un token avec la date et l'heure puis 
 * complète ce champ caché et l'envoie au serveur.
 *
 * Il met en place un timer pour vérifier l'arrivée du cookie
 * 
 * Le serveur, dans sa réponse doit donc renvoyer un cookie avec cette valeur.
 * Que la réponse soit positive ou pas, ne serait-ce que pour arrêter le timer et 
 * le blocage.
 *
 * Lorsque le cookie arrive, le timer appelle finishDownload qui retire le cookie et
 * débloque la page.
 */
var fileDownloadCheckTimer;
function blockUIForDownload() {
    window.clearInterval(fileDownloadCheckTimer);
    $.removeCookie('download_file_token', { path: '/' }); //remove the cookie
    var token = new Date().getTime(); //use the current timestamp as the token value

    $('#download_token_value_id').val(token);
    $('.inner-champ').block({ message: '<h1>Juste un instant...</h1>' });
    // $.blockUI();
    fileDownloadCheckTimer = window.setInterval(function () {
      var cookieValue = $.cookie('download_file_token');
      if (cookieValue == token)
       finishDownload();
    }, 1000);
  }


function finishDownload() {
 window.clearInterval(fileDownloadCheckTimer);
 $.removeCookie('download_file_token', { path: '/' }); //remove the cookie
 $('.inner-champ').unblock();
}





// Cette fonction permet de rendre une table sortable en indiquant une action
// à appeler par la fonction ajax
// Exemple fnTableSortable($('.admin_natures #recettes'), '/reorder');
// rend la table #recettes sortable sur elle-même en appelant l'action
// reorder du controller qui a affiché la vue (ici natures_controller#index)
// donc l'url sera par exemple periods/2/natures
// et l'url appelée par la fonction ajax sera periods/2/natures/reorder'
//
//L'attribut data-position de chaque ligne donne sa ligne d'origine
//Il faut donc trouver la position du drop
//puis envoyer au controller une action avec les paramètres id, fromPosition et 
//toPosition. 
//
function fnTableSortable(table, action) {
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
          if ($(this).attr('id') === id) {
            to = index;
          }

        });

        $.ajax({
          // l'action actuelle avec en plus l'action transmise en paramètre
          // celà permet pour une vue index de l'appeler avec /reorder
          // en supposant que l'action dans le controller est reorder
          // Si on est dans une action précise par exemple pointage,
          // cela permet de transmettre _reorder comme paramètre action
          // ce qui appelera l'action pointage_reorder dans le controller'
          url: window.location.pathname + action,
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
