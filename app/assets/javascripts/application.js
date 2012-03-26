// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require twitter/bootstrap
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
    jQuery.each($('.input_date'), function (index, val) {
        $(val).datepicker(
            {
                dateFormat: 'dd/mm/yy',
                buttonImage: '/assets/cal.gif',
                buttonImageOnly: true,
                showOn: 'both',
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
// fonction pour transformer une chaine en float
function stringToFloat(jcdata) {

    if (jcdata === undefined) {
        return 0.0;
    }
    var d = String(jcdata).replace(/,/, '.');
    if (isNaN(d)) {
        return 0.0;
    } else {
        return Number(d);
    }
}

// mise en forme des table
// il y a différents types de table, celle ci est une table sans total mais avec la première col qui doit être classée en asci
jQuery(function () {
    if ($('.simple_data_table_ascisort').length !== 0) {
        var oTable, nb_col, iCol, nTrs;
        oTable = $('.simple_data_table_ascisort').dataTable({
            "oLanguage": {
                "sUrl": "/frenchdatatable.txt"
            },
            "aoColumns": [
                {
                    "sType": "string"
                },
                null,
                null,
                {
                    "bSortable": false
                }
            ]
        });

        nb_col = $('tr td:nth-child(1)').length;
        $('td', oTable.fnGetNodes()).hover(function () {
            iCol = $('td', this.parentNode).index(this) % nb_col;
            nTrs = oTable.fnGetNodes();
            $('td:nth-child(' + (iCol + 1) + ')', nTrs).addClass('highlighted');
        }, function () {
            $('td.highlighted', oTable.fnGetNodes()).removeClass('highlighted');
        });

    }
});

