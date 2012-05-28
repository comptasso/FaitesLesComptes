

/* Table initialisation */
$(document).ready(function() {
	$('#admin_organism_table').dataTable( {
		"sDom": "<'row-fluid'<'span9'l><'span3'f>r>t<'row-fluid'<'span9'i><'span3'p> >",
		"sPaginationType": "bootstrap",
		"oLanguage": {
          "sUrl": "/frenchdatatable.txt"
			
		}
	} );
} );