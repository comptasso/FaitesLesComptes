/* 
 * Fichier ajouté par JC pour avoir des fonctionnalités nouvelles de DataTable
 * La première partie permet une adaptation de datatable et de bootstrap
 * La deuxième partie apporte des ajouts pour pouvoir trier sur des nombres avec une décimale.
 * et sur les dates au format français.
 */

// instruction de data-tables pour s'adapter à bootstrap'
$.extend($.fn.dataTableExt.oStdClasses, {
    "sWrapper": "dataTables_wrapper form-inline"
});

// NOTE : je n'utilise pas l'extension pour avoir le style bootstrap pour le tri
// car je préfère le style dataTables avec les petites icones images qui sont plus parlantes'
//$.extend( $.fn.dataTableExt.oStdClasses, {
//    "sSortAsc": "header headerSortDown",
//    "sSortDesc": "header headerSortUp",
//    "sSortable": "header"
//} );


/* API method to get paging information */
$.fn.dataTableExt.oApi.fnPagingInfo = function (oSettings) {
    return {
        "iStart":         oSettings._iDisplayStart,
        "iEnd":           oSettings.fnDisplayEnd(),
        "iLength":        oSettings._iDisplayLength,
        "iTotal":         oSettings.fnRecordsTotal(),
        "iFilteredTotal": oSettings.fnRecordsDisplay(),
        "iPage":          Math.ceil(oSettings._iDisplayStart / oSettings._iDisplayLength),
        "iTotalPages":    Math.ceil(oSettings.fnRecordsDisplay() / oSettings._iDisplayLength)
    };
};



/* Bootstrap style pagination control */
$.extend($.fn.dataTableExt.oPagination, {
    "bootstrap": {
        "fnInit": function (oSettings, nPaging, fnDraw) {
            var oLang, fnClickHandler, els;
            oLang = oSettings.oLanguage.oPaginate;
            fnClickHandler = function (e) {
                e.preventDefault();
                if (oSettings.oApi._fnPageChange(oSettings, e.data.action)) {
                    fnDraw(oSettings);
                }
            };

            $(nPaging).addClass('pagination').append(
                '<ul>' +
                    '<li class="prev disabled"><a href="#">&larr; ' + oLang.sPrevious + '</a></li>' +
                    '<li class="next disabled"><a href="#">' + oLang.sNext + ' &rarr; </a></li>' +
                    '</ul>'
            );
            els = $('a', nPaging);
            $(els[0]).bind('click.DT', { action: "previous" }, fnClickHandler);
            $(els[1]).bind('click.DT', { action: "next" }, fnClickHandler);
        },

        "fnUpdate": function (oSettings, fnDraw) {
            var iListLength = 5,
                iLen = 0,
                oPaging = oSettings.oInstance.fnPagingInfo(),
                an = oSettings.aanFeatures.p,
                i,
                j,
                sClass,
                iStart,
                iEnd,
                iHalf = Math.floor(iListLength / 2),
                jcf = function (e) {
                    e.preventDefault();
                    oSettings._iDisplayStart = (parseInt($('a', this).text(), 10) - 1) * oPaging.iLength;
                    fnDraw(oSettings);
                };

            if (oPaging.iTotalPages < iListLength) {
                iStart = 1;
                iEnd = oPaging.iTotalPages;
            } else if (oPaging.iPage <= iHalf) {
                iStart = 1;
                iEnd = iListLength;
            } else if (oPaging.iPage >= (oPaging.iTotalPages - iHalf)) {
                iStart = oPaging.iTotalPages - iListLength + 1;
                iEnd = oPaging.iTotalPages;
            } else {
                iStart = oPaging.iPage - iHalf + 1;
                iEnd = iStart + iListLength - 1;
            }

            for (i = 0, iLen = an.length; i < iLen; i += 1) {
                // Remove the middle elements
                $('li:gt(0)', an[i]).filter(':not(:last)').remove();

                // Add the new list items and their event handlers
                for (j = iStart; j <= iEnd; j += 1) {
                    sClass = (j === oPaging.iPage + 1) ? 'class="active"' : '';
                    $('<li ' + sClass + '><a href="#">' + j + '</a></li>')
                        .insertBefore($('li:last', an[i])[0])
                        .bind('click', jcf);
                }

                // Add / remove disabled classes from the static elements
                if (oPaging.iPage === 0) {
                    $('li:first', an[i]).addClass('disabled');
                } else {
                    $('li:first', an[i]).removeClass('disabled');
                }

                if (oPaging.iPage === oPaging.iTotalPages - 1 || oPaging.iTotalPages === 0) {
                    $('li:last', an[i]).addClass('disabled');
                } else {
                    $('li:last', an[i]).removeClass('disabled');
                }
            }
        }
    }
});


//plug in permettant d'ajouter le type comma-decimals aux colonnes'
jQuery.fn.dataTableExt.aTypes.unshift(
    function ( sData )
    {
        var regex = /-?[1-9](?:\d{0,2})(?:\s\d{3})*(?:,\d\d)|-?0,\d\d|-/;
        if (sData.match(regex)) {
          return 'numeric-comma';
        } else {
          return null;
        }
    }
);


// fonctions de tri pour des nombres avec une virgule comme séparateur décimal
    jQuery.fn.dataTableExt.oSort['numeric-comma-asc']  = function(a,b) {
    var x = (a === "-") ? 0 : a.replace( ',', "." ).replace(' ', '');
    var y = (b === "-") ? 0 : b.replace( ',', "." ).replace(' ', '');;
    x = parseFloat( x );
    y = parseFloat( y );
    return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

jQuery.fn.dataTableExt.oSort['numeric-comma-desc'] = function(a,b) {
    var x = (a === "-") ? 0 : a.replace( ',', "." ).replace(' ', '');;
    var y = (b === "-") ? 0 : b.replace( ',', "." ).replace(' ', '');;
    x = parseFloat( x );
    y = parseFloat( y );
    return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};


// dateHeight transforme une date au format français en un chiffre
// ce qui permet les comparaisons pour le tri des tables
// dateStr est au format jj/mm/aaaa
function dateHeight(dateStr) {
  // on cherche les 4 derniers chiffres
  var arr = dateStr.split('/');
  var val = arr[2] + arr[1] + arr[0];
  return parseInt(val)
}

jQuery.fn.dataTableExt.oSort['date-euro-asc'] = function(a, b) {
                        var x = dateHeight(a);
                        var y = dateHeight(b);
                        var z = ((x < y) ? -1 : ((x > y) ? 1 : 0));
                        return z;
                };

jQuery.fn.dataTableExt.oSort['date-euro-desc'] = function(a, b) {
                        var x = dateHeight(a);
                        var y = dateHeight(b);
                        var z = ((x < y) ? 1 : ((x > y) ? -1 : 0));
                        return z;
                };



