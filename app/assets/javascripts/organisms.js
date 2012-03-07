"use strict";
/*jslint browser: true */
var $, jQuery, stringToFloat;

// mise en forme des tables
jQuery(function () {
    if ($('.organisms .data_table').length !== 0) {
        var oTable = $('.organisms .data_table').dataTable({

            "oLanguage": {
                "sUrl": "/frenchdatatable.txt"
            },

            "fnFooterCallback": function (nRow, aaData, iStart, iEnd, aiDisplay) {
                /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */
                var iTotalDebit = 0.0, iTotalCredit = 0.0, i = 0, iPageDebit = 0.0, iPageCredit = 0.0, nCells;
                for (i = 0; i < aaData.length; i += 1) {
                    iTotalDebit += stringToFloat(aaData[i][1]);
                }

                for (i = iStart; i < iEnd; i += 1) {
                    iPageDebit += stringToFloat(aaData[aiDisplay[i]][1]);
                }

                for (i = 0; i < aaData.length; i += 1) {
                    iTotalCredit += stringToFloat(aaData[i][2]);
                }

                for (i = iStart; i < iEnd; i += 1) {
                    iPageCredit += stringToFloat(aaData[aiDisplay[i]][2]);
                }

                /* Modify the footer row to match what we want */
                nCells = nRow.getElementsByTagName('th');
                nCells[1].innerHTML =  iPageDebit.toFixed(2) + '<br/>' + iTotalDebit.toFixed(2);
                nCells[2].innerHTML =  iPageCredit.toFixed(2) + '<br/>' + iTotalCredit.toFixed(2);
            }
        });

        $('td', oTable.fnGetNodes()).hover(function () {
            var iCol, nTrs;
            iCol = $('td', this.parentNode).index(this) % 3;
            nTrs = oTable.fnGetNodes();
            $('td:nth-child(' + (iCol + 1) + ')', nTrs).addClass('highlighted');
        }, function () {
            $('td.highlighted', oTable.fnGetNodes()).removeClass('highlighted');
        });

    }
}); // fin de jQuery application#data_table


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
    var complete_id, id, legend, ticks, period_ids, s = [], label = [], i = 0;
    $(element).each(function () { // pour chacun des graphiques mensuels (chacun des livres plus result)
        // on construit les variables qui seront utilisées par jqplot
        complete_id = this.id;
        id = this.id.match(/\d+$/); // on récupère l'id'
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
        dlabel: label
    };
}


// fonction pour tracer les graphes qui apparaissent dans la page organism#show
$(document).ready(function () {
    var all_datas;
    $.jqplot.config.enablePlugins = true; // semble indispensable pour le highlighter

    $('.monthly_graphic').each(function () {
        // on récupère les données à partir de span hidden
        all_datas = recup_graph_datas(this);

        // puis on trace le graphique avec ses options
        $.jqplot('chart_' + all_datas.dcomplete_id, all_datas.dseries, {
            // The "seriesDefaults" option is an options object that will
            // be applied to all series in the chart.
            seriesDefaults: {
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
            },


            // Custom labels for the series are specified with the "label"
            // option on the series option.  Here a series option object
            // is specified for each series.
            series: all_datas.dlabel,
            highlighter: {
                sizeAdjust: 2,
                tooltipLocation: 'n',
                tooltipAxes: 'y',
                tooltipFormatString: '%.2f',
                useAxesFormatters: true
            },
            // Show the legend and put it outside the grid, but inside the
            // plot container, shrinking the grid to accomodate the legend.
            // A value of "outside" would not shrink the grid and allow
            // the legend to overflow the container.
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
                        formatString: '\u20ac %d'
                    }
                }
            }
        });


        // avant de relier les colonnes des graphes à l'affichage du livre correspondant
        if (all_datas.did > 0) {   // le graphe 0 est celui des résultats - il n'est donc pas relié
            $('#chart_bar_book_' + all_datas.did).bind('jqplotDataClick',
                function (ev, seriesIndex, pointIndex, data) {
                    window.location = ("/books/" + all_datas.did + "/lines?mois=" + pointIndex + "&period_id=" + all_datas.dperiod_ids[seriesIndex]);
                });
        }
    });
});

function options_for_graph(all_datas, type) {
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
    };
    return options;
}

$(document).ready(function () {
    // $.jqplot.config.enablePlugins = true; // semble indispensable pour le highlighter
    var all_datas, options;
    
    // on récupère les données à partir de span hidden
    $('.line_monthly_graphic').each(function () { // pour chacun des graphiques mensuels (chacun des livres plus result)
        all_datas = recup_graph_datas(this);
        options = options_for_graph(all_datas, 'normal')
        $.jqplot('chart_' + all_datas.dcomplete_id, all_datas.dseries, {
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

        });
    });
});