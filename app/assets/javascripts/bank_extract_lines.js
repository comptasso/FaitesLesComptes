jQuery(function() {
  $('.public_bank_extract_lines .row_detail').hide();

  $('.public_bank_extract_lines .toggle-detail').click(function () {
    // identifier l'id de l'objet,
      var objid = $(this).attr('id');
    // construire une variable avec l'id pour avoir la classe  des rangées de détail
      var classid = '.' + objid;
      $('.champ h3 ').html(classid);
       $(classid).toggle();
       if ($(classid).is(':visible')) {
         $(this).html("&#x229F;");
       } else
         {
          $(this).html("&#x229E;");
         }
  })



});
