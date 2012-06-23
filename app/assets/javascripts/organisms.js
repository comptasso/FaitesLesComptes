"use strict";
/*jslint browser: true */

var $, jQuery, stringToFloat;

// fonction qui masque le contenu de la zone message dans le dashboard
// et associé le click sur l'enveloppe au toggle des messages
$(document).ready(function () {
    $('#mail_ul').hide();
    $('#mail_img').click(function () {
        $('#mail_ul').toggle();
    });
});

/*jslint nomen: true*/

// mise en forme de la table index des organismes
jQuery(function () {
    /* Table initialisation */
    $('.public_organisms .data_table').dataTable({
        "sDom": "<'row-fluid'<'span9'l><'span3'f>r>t<'row-fluid'<'span9'i><'span3'p> >",
        "bAutoWidth": false,
        "sPaginationType": "bootstrap",
        "aoColumns": [
            { "sWidth": "40%" },
            { "sWidth": "50%" },
            { "sWidth": "10%" },
        ],
        "oLanguage": {
            "sUrl": "/frenchdatatable.txt"
        }
    });
});
//    fin de jQuery application#data_table


// petite fonction helper pour transformer des strings en float.
// si ce n'est pas un nombre, transforme NaN en null. Ceci est
// nécessaire pour ne pas générer d'erreur lorsqu'une donnée
// est absente. Cas d'un exercice incomplet par exemple.
function s_to_f(element) {
    var e = parseFloat(element);
    if (isNaN(e)) {
        e = null;
    }
    return e;
}

// cette fonction récupère les informations cachées qui sont inclus dans un DOM
// à partir de l'id et des classes legend, ticks, period_ids et series'
function recup_graph_datas(element) {
    var complete_id, type, id, legend, ticks, period_ids, s = [], label = [], i = 0;
    $(element).each(function () { // pour chacun des graphiques mensuels (chacun des livres plus result)
        // on construit les variables qui seront utilisées par jqplot
        complete_id = this.id;
        type = $(this).attr('class').split('_')[0];
        id = this.id.match(/\d+$/)[0]; // on récupère l'id et comme match retourne un array on prend le premier'
        legend = $(this).find('.legend').text().split(';'); // la légende
        ticks = $(this).find('.ticks').text().split(';'); // les mois
        period_ids = $(this).find('.period_ids').text().split(';'); // les mois
        // et on les remplit par une boucle qui prend la dimension de légende pour construire
        for (i = 0; i <= legend.length; i += 1) {
            label[i] = {
                label: legend[i] // la table des légendes
            };
            s[i] = $(this).find('.series_' + i).text().split(';').map(s_to_f); // et chaque série de données
        }
    });
    // on retourne maintenant l'objet ainsi construit reprenant la totalité des infos
    return {
        dcomplete_id: complete_id,
        did: id,
        dlegend: legend,
        dticks: ticks,
        dperiod_ids: period_ids,
        dseries: s,
        dlabel: label,
        dtype: type
    };
}




// prend les données d'un graphe (fournies par un appel à recup_graph_datas)
// et un type de graphe ('normal' ou 'bar') et construit les options qui seront
// nécessaires pour jqplot (legende, séries, ticks,...)
function options_for_graph(all_datas) {
    var options = {
        seriesDefaults: {
            pointLabels: {
                show: false
            },
            lineWidth: 2,
            markerOptions: {
                size: 3,
                style: "circle"
            }
        },
        series: all_datas.dlabel,
        highlighter: {
            sizeAdjust: 5,
            tooltipLocation: 'n',
            tooltipAxes: 'y',
            useAxesFormatters: true
        },
        legend: {
            renderer: $.jqplot.EnhancedLegendRenderer,
            //  numberRows: 1,
            //  numberColumns: 2,
            show: true,
            placement: 'insideGrid',
            location: 'ne',
            fontSize: '8pt',
            textColor: 'blue',
            rendererOptions: {
                numberRows: 1,
                numberColumns: all_datas.dlegend.length
            }
        },
        cursor: {
            show: false,
            zoom: false,
            looseZoom: false,
            showTooltip: false
        },
        axes: {
            // Use a category axis on the x axis and use our custom ticks.
            xaxis: {
                renderer: $.jqplot.CategoryAxisRenderer,
                ticks: all_datas.dticks,
                tickRenderer: $.jqplot.CanvasAxisTickRenderer,
                tickOptions: {
                    angle: 0,
                    fontSize: '8pt',
                    showMark: true,
                    showGridline: false
                }
            },

            // Pad the y axis just a little so bars can get close to, but
            // not touch, the grid boundaries.  1.2 is the default padding.
            yaxis: {
                pad: 1.05,
                tickOptions: {
                    formatString: "\u20ac %d"
                }
            }
        }
    }; // fin des default options pour un graphe normal

    // ici on surcharge seriesDefaults pour les graphes de type 'bar'
    if (all_datas.dtype === 'bar') {
        // le renderer bar et ces options
        options.seriesDefaults = {
            renderer: $.jqplot.BarRenderer,
            pointLabels: {
                show: false
            },
            rendererOptions: {
                fillToZero: true,
                barPadding: 0,      // number of pixels between adjacent bars in the same
                // group (same category or bin).
                barMargin: 5,      // number of pixels between adjacent groups of bars.
                barDirection: 'vertical', // vertical or horizontal.
                barWidth: 10,     // width of the bars.  null to calculate automatically.
                shadowOffset: 0,    // offset from the bar edge to stroke the shadow.
                shadowDepth: 0,     // nuber of strokes to make for the shadow.
                shadowAlpha: 0 // transparency of the shadow.
            //, location: 'e', edgeTolerance: -15 }
            }
        };
    }
    return options;
}

function bind_bars(all_datas) {
    $('#chart_' + all_datas.dcomplete_id).bind('jqplotDataClick',
        function (ev, seriesIndex, pointIndex, data) {
            window.location = ("/books/" + all_datas.did + "/lines?mois=" + pointIndex + "&period_id=" + all_datas.dperiod_ids[seriesIndex]);
        });
}

// la fonctio monthly_graphic est appelée par des éléments du class
// .bar_... ou .line... et fait le travail de tracé de graphique et
// éventuellement de liens avec les évènements clics sur les barres pour
// les objets de type book (sauf book 0 qui est le résultat)
function monthly_graphic(element) {
    var all_datas, options;
    // pour chacun des graphiques mensuels
    all_datas = recup_graph_datas(element);  // on récupère les données à partir de span hidden
    options = options_for_graph(all_datas); // on construit les options
    $.jqplot('chart_' + all_datas.dcomplete_id, all_datas.dseries, options); // et on trace dans l'id chart_cash_id_1 ou chart_book_id_2'
    // puis on relie les colonnes des graphes à l'affichage du livre correspondant lorsqu'il s'agit d'un book
    // et lorsque ce n'est pas le book 0 qui est celui du résultats
    if (all_datas.dcomplete_id.match(/book/) && all_datas.did > 0) {
        bind_bars(all_datas); // fait le lien avec les barres
    }
}

// fonction pour tracer les graphes qui apparaissent dans la page organism#show
$(document).ready(function () {
    $.jqplot.config.enablePlugins = true; // semble indispensable pour le highlighter
    $('.bar_monthly_graphic').each(function () {
        monthly_graphic(this); // on trace le graphe qui renvoie l'ensemble des données
    });
    // trace un graphe sous forme de ligne pour les classes line_monthly_graphic
    // en pratique les comptes bancaires et les caisses
    $('.line_monthly_graphic').each(function () {
        monthly_graphic(this);
    });
});

