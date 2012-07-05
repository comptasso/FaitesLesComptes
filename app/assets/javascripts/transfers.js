


/* Table initialisation */

$(document).ready(function() {
	$('#transfer-table').dataTable( {
    "sDom": 'lfrtip',
		"sPaginationType": "bootstrap",
		"oLanguage": {
          "sUrl": "/frenchdatatable.txt"   // ce fichier est dans /public

		},
     "aoColumnDefs": [
    {
      "bSortable": false,
      "aTargets": ['actions' ]
    },
    {
      "sType": "date-euro",
      "asSortable": ['asc', 'desc'],
      "aTargets": ['date-euro'] // les colonnes date au format français ont la classe date-euro
    }]


	} );
} );