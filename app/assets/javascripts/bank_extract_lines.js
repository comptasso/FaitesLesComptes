jQuery(function() {

// utilisé pour afficher les détails des lignes de chèques
// supprimé comme fonctions car les lignes supplémentaires étaient incompatibles
// avec le drag and drop des lignes de la table.
//  // masquer les lignes de détail à l'affichage'
//  $('.public_bank_extract_lines .row_detail').hide();
//
//  // associer le click au span
//  $('.public_bank_extract_lines .toggle-detail').click(function () {
//    // identifier l'id de l'objet,
//      var objid = $(this).attr('id');
//    // construire une variable avec l'id pour avoir la classe  des rangées de détail
//      var classid = '.' + objid;
//      $(classid).toggle();
//       if ($(classid).is(':visible')) {
//         $(this).html("&#x229F;");
//       } else
//         {
//          $(this).html("&#x229E;");
//         }
//  });

  $('.public_bank_extract_lines .data_table').dataTable({
      "bPaginate": false,
      "bLengthChange": false,
      "bFilter": false,
      "bInfo": false
  })
  .rowReordering({
    // appel de l'action reorder de bank_extract_lines_controller après un reclassement des lignes
    sURL: window.location + "/reorder"
  });
});
