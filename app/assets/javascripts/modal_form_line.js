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

"use strict";
/*jslint browser: true */
/*global $, jQuery , stringToFloat, $f_numberWithPrecision*/

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
        $('optgroup[label="Depenses"]').attr('disabled', true);
        $('optgroup[label="Recettes"]').attr('disabled', false);
        $("#in_out_writing_compta_lines_attributes_1_payment_mode option[value='Chèque']").attr('disabled', true);
    }
    if (income_outcome.match(/^D/) !== null) {
        
        $('label[for="in_out_writing_compta_lines_attributes_0_debit"]').parent().show();
        $('label[for="in_out_writing_compta_lines_attributes_0_credit"]').parent().hide();
        $('optgroup[label="Depenses"]').attr('disabled', false);
        $('optgroup[label="Recettes"]').attr('disabled', true);
        $("#in_out_writing_compta_lines_attributes_1_payment_mode option[value='Chèque']").attr('disabled', false);
    }
}

function $f_modal_payment_mode_change() {
  if ($('#in_out_writing_compta_lines_attributes_1_payment_mode').val() === 'Chèque') {
            $('label[for="in_out_writing_compta_lines_attributes_1_check_number"]').parent().show();
        } else {
            $('label[for="in_out_writing_compta_lines_attributes_1_check_number"]').parent().hide();
        }
}

function $f_modal_raz() {
        var select_nature_id = $('#in_out_writing_compta_lines_attributes_0_nature_id');
        var select_dest_id = $('#in_out_writing_compta_lines_attributes_0_destination_id');
        var select_payment_mode = $('#in_out_writing_compta_lines_attributes_1_payment_mode');
  
        // on vide tous les champs
        $('#in_out_writing_narration').val('');
        $('#in_out_writing_ref').val('');
        select_nature_id.val('');
        select_dest_id.val('');
        $('#in_out_writing_compta_lines_attributes_0_credit').val('0.00');
        $('#in_out_writing_compta_lines_attributes_0_debit').val('0.00');
        select_payment_mode.val('');
        $('#in_out_writing_compta_lines_attributes_1_check_number').val('');
        $('label[for="in_out_writing_compta_lines_attributes_1_check_number"]').parent().hide();
        // on retire les éventuels messages d'erreur, au cas où on soit passé par une 
        // telle phase
        $('#modal_form_line .alert').remove(); // retrait du message des erreurs ont été trouvées
        $('#modal_form_line div').removeClass('error'); // retrait des classes erreurs
        $('#modal_form_line .help-inline').remove(); // retrait des classes erreurs
        
        // on enlève les selected éventuels
        $('#in_out_writing_compta_lines_attributes_0_nature_id option').removeAttr('selected');
        $('#in_out_writing_compta_lines_attributes_0_destination_id option').removeAttr('selected');
        $('#in_out_writing_compta_lines_attributes_1_payment_mode option').removeAttr('selected');
        
  
       // On ne peut réintroduire les prompts que par javascript car Rails ne les affiche pas
       // lorsque le champ a déjà une sélection.
       if (select_nature_id.find('option[value=""]').length === 0) {
          select_nature_id.prepend('<option value="">Quoi ?</option>;');
          select_nature_id.find('option[value=""]').attr('selected', "selected");
        }
        if (select_dest_id.find('option[value=""]').length === 0) {
          select_dest_id.prepend('<option value="">Pour qui ?</option>;');
          select_dest_id.find('option[value=""]').attr('selected', "selected");
        }
        if (select_payment_mode.find('option[value=""]').length === 0) {
          select_payment_mode.prepend('<option value="">Mode de réglement</option>;');
          select_payment_mode.find('option[value=""]').attr('selected', "selected");
        }
        
    }


jQuery(function () {

    
    $f_modal_book_change();
    // selon la nature du livre, on veut disable les natures qui sont inadaptées
    $('#modal_form_line').on('change', '#in_out_writing_book_id', $f_modal_book_change);
    // Attacher un évènement onChange au champ book
    $('#modal_form_line').on('change', '#in_out_writing_compta_lines_attributes_1_payment_mode', $f_modal_payment_mode_change);
       
    $('#modal_form_line').on('shown', $f_modal_raz);
});