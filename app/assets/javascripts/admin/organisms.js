/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
// mise en forme de la table index des organismes
jQuery(function () {
   
  $.extend( $.fn.dataTableExt.oStdClasses, {
    "sWrapper": "dataTables_wrapper form-inline"
} );

  /* Table initialisation */
        
        $('#admin_organism_table').dataTable({
          "sDom": "<'row'<'span6'p><'span6'f>r>t<'row'<'span6'i><'span6'l>>",
          "sPaginationType": "full_numbers"
          //  "sDom": "<'row-fluid'<'span6'l><'span6' f> >rt<'row-fluid'p>",
//            "bAutoWidth": false,
//            "sPaginationType": "two_button",
//            "oLanguage": {
//                "sUrl": "/frenchdatatable.txt"
//            }
        });
    
});



