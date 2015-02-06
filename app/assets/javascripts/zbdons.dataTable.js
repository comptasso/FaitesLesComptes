"use strict";
/*jslint browser: true */
/*jslint nomen: true */
/*global $, jQuery */

// nomen true est là pour éviter une remarque de jslint sur les noms commençant
// par _ et pour lesquels je ne peux rien car venant de dataTable

/* 
 * Fichier ajouté par JC pour avoir des fonctionnalités nouvelles de DataTable
 * La deuxième partie apporte des ajouts pour pouvoir trier sur des nombres avec une décimale.
 * et sur les dates au format français.
 */





//plug in permettant d'ajouter le type numeric-comma aux colonnes'
jQuery.fn.dataTableExt.aTypes.unshift(
    function (sData) {
        var regex = /^-?[1-9](?:\d{0,2})(?:\s\d{3})*(?:,\d\d)$|^-?0,\d\d$|^-$/;
        if (sData.match(regex)) {
            return 'numeric-comma';
        } else {
            return null;
        }
    }
);


// fonctions de tri pour des nombres avec une virgule comme séparateur décimal
jQuery.fn.dataTableExt.oSort['numeric-comma-asc']  = function (a, b) {
    var x = (a === "-") ? 0 : a.replace(',', ".").replace(' ', ''),
        y = (b === "-") ? 0 : b.replace(',', ".").replace(' ', '');
    x = parseFloat(x);
    y = parseFloat(y);
    return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

jQuery.fn.dataTableExt.oSort['numeric-comma-desc'] = function (a, b) {
    var x = (a === "-") ? 0 : a.replace(',', ".").replace(' ', ''),
        y = (b === "-") ? 0 : b.replace(',', ".").replace(' ', '');
    x = parseFloat(x);
    y = parseFloat(y);
    return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};


// dateHeight transforme une date au format français en un chiffre
// ce qui permet les comparaisons pour le tri des tables
// dateStr est au format jj/mm/aaaa
function dateHeight(dateStr) {
  // on cherche les 4 derniers chiffres
    var arr = dateStr.split('/'),
        val = arr[2] + arr[1] + arr[0];
    return parseInt(val, 10);
}

// TODO on pourrait utiliser une fonction dataType pour enregistrer les 
// formats date européens (voir plus haut pour ce qui a été fait pour le 
// format monétaire.

jQuery.fn.dataTableExt.oSort['date-euro-asc'] = function (a, b) {
    var x = dateHeight(a), y = dateHeight(b),
        z = ((x < y) ? -1 : ((x > y) ? 1 : 0));
    return z;
};

jQuery.fn.dataTableExt.oSort['date-euro-desc'] = function (a, b) {
    var x = dateHeight(a), y = dateHeight(b),
        z = ((x < y) ? 1 : ((x > y) ? -1 : 0));
    return z;
};



