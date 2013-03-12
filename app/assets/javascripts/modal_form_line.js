/* 
 * Ce fichier gère les interactions de la boîte modale utilisée
 * pour rajouter une ligne d'écriture lorsque l'on est dans l'action
 * pointage d'extrait bancaire et que l'on constate que des lignes
 * doivent être ajoutées.
 *
 * La sélection du type de livre est faite par le label de la liste
 * déroulante qui commence par un R pour les recettes
 * et par un D pour les dépenses.
 * 
 */

 function $f_modal_book_change() {
    // lire la valeur du champ et déterminer si c'est une recette ou une dépense
    var income_outcome = $('#in_out_writing_book_id option:selected').text();
    $('#form_bank_extract_line #in_out_writing_compta_lines_attributes_0_credit').val('0.00');
    $('#form_bank_extract_line #in_out_writing_compta_lines_attributes_0_debit').val('0.00');
    if ($('#form_bank_extract_line #in_out_writing_compta_lines_attributes_0_payment_mode') === 'Chèque') {
      $('label[for="in_out_writing_compta_lines_attributes_1_check_number"]').parent().show();
    }

    // et agit en conséquence - on affiche les champs débit ou credit
    // on désactive les natures qui ne sont pas adaptées au livre
    if (income_outcome.match(/^R/) !== null) {
      $('label[for="in_out_writing_compta_lines_attributes_0_debit"]').parent().hide();
      $('label[for="in_out_writing_compta_lines_attributes_0_credit"]').parent().show();
      $('optgroup[label="Depenses"]').attr('disabled', true)
      $('optgroup[label="Recettes"]').attr('disabled', false)
      $("#in_out_writing_compta_lines_attributes_1_payment_mode option[value='Chèque']").attr('disabled', true)
    }
    if (income_outcome.match(/^D/) !== null) {
      $('label[for="in_out_writing_compta_lines_attributes_0_debit"]').parent().show();
      $('label[for="in_out_writing_compta_lines_attributes_0_credit"]').parent().hide();
      $('optgroup[label="Depenses"]').attr('disabled', false)
      $('optgroup[label="Recettes"]').attr('disabled', true)
      $("#in_out_writing_compta_lines_attributes_1_payment_mode option[value='Chèque']").attr('disabled', false)
    }
  }


jQuery(function() {
  
 
  function $f_modal_raz() {
    $('#in_out_writing_narration').val('');
    $('#in_out_writing_ref').val('');
    $('#in_out_writing_compta_lines_attributes_0_nature_id').val('');
    $('#in_out_writing_compta_lines_attributes_0_destination_id').val('');
    $('#in_out_writing_compta_lines_attributes_0_credit').val('0.00');
    $('#in_out_writing_compta_lines_attributes_0_debit').val('0.00');
    $('#in_out_writing_compta_lines_attributes_1_payment_mode').val('');
    $('label[for="in_out_writing_compta_lines_attributes_1_check_number"]').parent().hide();
  }


  $f_modal_book_change();
  // selon la nature du livre, on veut disable les natures qui sont inadaptées
  // Attacher un évènement onChange au champ book
  $('#form_bank_extract_line #in_out_writing_book_id').change($f_modal_book_change);
  $('#form_bank_extract_line #in_out_writing_compta_lines_attributes_1_payment_mode').change(function() {
    if ($(this).val() === 'Chèque') {
      $('label[for="in_out_writing_compta_lines_attributes_1_check_number"]').parent().show();
    } else {
      $('label[for="in_out_writing_compta_lines_attributes_1_check_number"]').parent().hide();
    }
  });

  $('#modal_form_line').on('shown', $f_modal_raz);
  
});
