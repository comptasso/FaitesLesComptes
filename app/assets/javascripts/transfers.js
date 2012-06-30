


/* Table initialisation */

$(document).ready(function() {
	$('#transfer-table').dataTable( {
    "sDom": 'lfrtip',

		"sPaginationType": "bootstrap",
		"oLanguage": {
          "sUrl": "/frenchdatatable.txt"   // ce fichier est dans /public

		}

	} );
} );