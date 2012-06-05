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

jQuery(function() {
  
  function $f_modal_book_change() {
    // lire la valeur du champ et déterminer si c'est une recette ou une dépense
    var income_outcome = $('#line_book_id option:selected').text();
    $('#form_bank_extract_line #line_credit').val('0.00');
    $('#form_bank_extract_line #line_debit').val('0.00');
    if ($('#form_bank_extract_line #line_payment_mode') === 'Chèque') {
      $('#td_check_number').show();
    }


    if (income_outcome.match(/^R/) !== null) {
      $('label[for="line_debit"]').parent().hide();
      $('label[for="line_credit"]').parent().show();
      $('optgroup[label="Depenses"]').attr('disabled', true)
      $('optgroup[label="Recettes"]').attr('disabled', false)

    }
    if (income_outcome.match(/^D/) !== null) {
      $('label[for="line_debit"]').parent().show();
      $('label[for="line_credit"]').parent().hide();
      $('optgroup[label="Depenses"]').attr('disabled', false)
      $('optgroup[label="Recettes"]').attr('disabled', true)
    }
  }

  function $f_modal_raz() {
    $('#line_narration').val('');
    $('#line_ref').val('');
    $('#line_nature_id').val('');
    $('#line_destination_id').val('');
    $('#line_credit').val('0.00');
    $('#line_debit').val('0.00');
    $('#line_payment_mode').val('');
  }


  $f_modal_book_change();
  // selon la nature du livre, on veut disable les natures qui sont inadaptées
  // Attacher un évènement onChange au champ book
  $('#form_bank_extract_line #line_book_id').live('change', $f_modal_book_change);
  $('#form_bank_extract_line #line_payment_mode').live('change', function() {
    if ($(this).val() === 'Chèque') {
      $('#form_bank_extract_line #td_check_number').show();
    } else {
      $('#form_bank_extract_line #td_check_number').hide();
    }
  });

  $('#modal_form_line').on('shown', $f_modal_raz);
  // de même on veut masquer crédit ou débit
});
