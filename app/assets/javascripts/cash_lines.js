// mise en forme des tables de lignes
jQuery(function() {
    if ($('.cash_lines .data_table').length != 0) {
        var oTable= $('.cash_lines .data_table').dataTable(
        {
            "oLanguage": {
                "sUrl": "/frenchdatatable.txt"
            },
 "aoColumns": [
            null,
            null,
            null,
            null,
             null,
            null,
            {"bSortable": false},
            {"bSortable": false}
            ],

            "fnFooterCallback": function ( nRow, aaData, iStart, iEnd, aiDisplay ) {
                /*
             * Calculate the total market share for all browsers in this table (ie inc. outside
             * the pagination)
             */
                var iTotalDebit = 0;
                for ( var i=0 ; i<aaData.length ; i++ )
                {
                    iTotalDebit += stringToFloat(aaData[i][4]);
                }

                /* Calculate the market share for browsers on this page */
                var iPageDebit = 0.0
                for ( var i=iStart ; i<iEnd ; i++ )
                {
                    iPageDebit += stringToFloat(aaData[aiDisplay[i] ][4]);
                }

                var iTotalCredit = 0.0
                for ( var i=0 ; i<aaData.length ; i++ )
                {
                    iTotalCredit += stringToFloat(aaData[i][5]);
                }

                /* Calculate the market share for browsers on this page */
                var iPageCredit = 0.0;
                for ( var i=iStart ; i<iEnd ; i++ )
                {
                    iPageCredit += stringToFloat(aaData[ aiDisplay[i] ][5]);
                }

                /* Modify the footer row to match what we want */
                var nCells = nRow.getElementsByTagName('th');
                nCells[1].innerHTML =  iPageDebit.toFixed(2) +'<br/>'+ iTotalDebit.toFixed(2);
                nCells[2].innerHTML =  iPageCredit.toFixed(2)+'<br/>'+ iTotalCredit.toFixed(2);

            }

        });


        $('td', oTable.fnGetNodes()).hover( function() {
            var iCol = $('td', this.parentNode).index(this) % 7;
            var nTrs = oTable.fnGetNodes();
            $('td:nth-child('+(iCol+1)+')', nTrs).addClass( 'highlighted' );
        }, function() {
            $('td.highlighted', oTable.fnGetNodes()).removeClass('highlighted');
        } );
    }
});



