

jQuery(function() {
    if ($('.bank_accounts .data_table').length !== 0) {
        $('.bank_accounts .data_table').dataTable({
         
            "oLanguage": {
                "sUrl": "/frenchdatatable.txt" 
            },
            "aoColumns": [ 
            null,
            null,
            null,
            null,
            
            {"bSortable": false},
            {"bSortable": false}
            ]
        }

        );
    }
});

