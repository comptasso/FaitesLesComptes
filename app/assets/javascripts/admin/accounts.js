// mise en forme des tables de lignes
jQuery(function() {
    if ($('.accounts .data_table').length != 0) {
        var oTable= $('.accounts .data_table').dataTable(
        {
            "oLanguage": {
                "sUrl": "/frenchdatatable.txt"
            },
 "aoColumns": [
            null,
            null,
            null,
           {"bSortable": false}
            ]

        });
        
        var nCells=$('tbody tr:nth-child(1) td').length;
        $('td', oTable.fnGetNodes()).hover( function() {

            var iCol = $('td', this.parentNode).index(this) % nCells;
            var nTrs = oTable.fnGetNodes();
            $('td:nth-child('+(iCol+1)+')', nTrs).addClass( 'highlighted' );
        }, function() {
            $('td.highlighted', oTable.fnGetNodes()).removeClass('highlighted');
        } );
    }
});



