jQuery(function() {
  // masquer les lignes de détail à l'affichage'
  $('.public_bank_extract_lines .row_detail').hide();

  // associer le click au span
  $('.public_bank_extract_lines .toggle-detail').click(function () {
    // identifier l'id de l'objet,
      var objid = $(this).attr('id');
    // construire une variable avec l'id pour avoir la classe  des rangées de détail
      var classid = '.' + objid;
      $(classid).toggle();
       if ($(classid).is(':visible')) {
         $(this).html("&#x229F;");
       } else
         {
          $(this).html("&#x229E;");
         }
  });

  $('.public_bank_extract_lines .data_table').dataTable()
  .rowReordering({
    sURL: window.location + "/reorder"
  });
});
