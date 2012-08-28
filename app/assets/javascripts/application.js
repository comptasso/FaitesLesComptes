// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require jquery.dataTables
//= require jquery.jqplot.min
//= require jqplot
//= require_tree .
//
//
//
//

"use strict";
/*jslint browser: true */
var $, jQuery;
// fonction permettant de modifier un attribut booléen
// le script retourné par la fonction est alors utilisé pour remplacer le lien.
// utilisé notamment dans le verrouillage des écritures
$(document).ready(function () {
    $('a[id ^=lock_open]').click(function () {
        $.post($(this).attr('href'), null, null, "script");
        return false;
    });
});

$('.dropdown-toggle').dropdown();


// fonction utilisée pour afficher un date picker pour chaque champ de class
// .input_date. Ces champs imput_date sont créés facilement par la fonction
// picker_date qui est dans application_helper. Date min et
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

// FIXME traiter le cas ou data == nil
// fonction pour transformer une chaine avec virgule en float
function stringToFloat(jcdata) {

    if (jcdata === undefined) {
        return 0.0;
    }
    var d = String(jcdata).replace(/,/, '.');
    d = d.replace(/\s/, '');
    if (isNaN(d)) {
        return 0.0;
    } else {
        return Number(d);
    }
}

function numberWithPrecision(number) {
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


