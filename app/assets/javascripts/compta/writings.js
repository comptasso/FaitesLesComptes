"use strict";
/*global document, $, jQuery */

//var $, jQuery;

// la mise en forme des champs de saise des montants (debit et credit) est assurée
// par la classe .decimal et les fonctions qui sont définies dans application.js
// $f_empty pour vider un champ quand on entre et qu'il est à zero
// $f_two_decimals pour mettre deux décimales quand on sort du champ et le
// remettre à zero si on a rien rentré.

// On cache tous les sigles plus sauf celui de la dernière ligne
// puis on relie le click de cette image au lien qui ajoute la ligne
//
function $deal_icon_plus(e) {
  var bouton = $(this); //on mémorise le bouton cliqué pour pouvoir 
  // l'effacer en cas de succès
  // on trouve quel est le dernier numéro de ligne existant dans la page
  var lastid = $('.writing_line_form').filter(":last").
          find('input.numeric.decimal.debit').attr('id').split('_')[4];
  // enfin, on prépare l'url demandée. Il faut remplacer /edit ou /new
  // par '/add_line?num_line=' + lastid
  var chemin = window.location.pathname;
  if (chemin.match('new')) {
    chemin = chemin.replace('/new', '/add_line?num_line=' + lastid);
  } else {
    chemin = chemin.replace('/edit', '/add_line?num_line=' + lastid);
  }


  $.ajax({
    url: chemin,
    type: 'post',
    success: function(data, textStatus, jqXHR) {
      bouton.hide(); // on masque l'icone + sur laquelle on vient de cliquer
      $('h3').text('Dans la partie succès');
      // pour la nouvelle ligne affichée, on rattache les évènements 
      $('.compta_writings .writing_line_form:visible:last a.remove_form_line').
              bind('click', $remove_writing_line_form);
      $('.compta_writings .writing_line_form:visible:last a.add_form_line').
              bind('click', $deal_icon_plus);
    }
  });


}

// renvoie le total correspondant au selector mais seulement pour les lignes
// visibles.
// Cette fonction est utilisée par $balance qui fait appel à $total_sel('.credit')
// et à $total_sel('.debit')
function $total_sel(selector) {
  var t = 0;
  $(selector).each(function(index) {
    if ($(this).closest('.writing_line_form').is(':visible')) {
      t = t + parseFloat($(this).val(), 10);
    }
  });
  return t;
}

function $balance() {
  return ($total_sel('.credit') - $total_sel('.debit')).toFixed(2);
}



// fait la somme des débit et la somme des credits et retourne un booleen indiquant l'égalité
function $balanced() {
  if ($total_sel('.debit') === $total_sel('.credit')) {
    return true;
  } else {
    return false;
  }
}

// retourne le nombre de lignes qui ait soit débit soit credit de rempli
function $nb_lines() {
  var i = 0;
  $('.compta_writings .writing_line_form').each(function(index) {
    if (($(this).find('.debit:first').val() !== '0.00') || ($(this).find('.credit:first').val() !== '0.00')) {
      i = i + 1;
    }

  });
  return i;
}

// vérifie si la ligne peut être enregistrée et affiche le bouton si oui
// deux conditions sont testées : au moins une ligne remplie et une écriture équilibrée
// Affiche le solde dans la zone h3
function $check_submit() {
  var bal = $balance(), nb_lines = $nb_lines();
  if ((bal === '0.00') && (nb_lines > 1)) {
    $('input.btn').show();
  } else {
    $('input.btn').hide();
  }
  $('h3 #sold_value').text(bal);
}

// retire une compta_line du formulaire ou plutôt la cache
function $remove_writing_line_form() {
  console.log('bonjour');
  var wlf = $(this).closest(".writing_line_form");
  // marque le champ caché pour la suppression   
  $(this).prev("input[type=hidden]").val("1");
  wlf.hide();
  // on montre le bouton plus de la dernière ligne visible
  $('.compta_writings .writing_line_form:visible:last a.add_form_line').show();
  // on vérifie que l'on peut afficher le bouton submit
  $check_submit();
}




// il ne peut y avoir une ligne ayant à la fois débit et crédit de rempli
// donc on fait une fonction qui lorsqu'on quitte le champ remet à zero son
// correspondant si le montant est différent de zero
function $zero_field() {
// on ne fait rien si le champ est à zéro ou s'il est vide'
  if (($(this).val() === '0.00') || ($(this).val() === '')) {
    return;
  }

//  if (parseFloat($(this).val(), 10) == 0.00) {
//    return
//  }
  // sinon on cherche qui on est (soit credit soit débit)
  // et on remet à zero l'autre champ
  if ($(this).hasClass('debit') === true) {
    $(this).closest('.writing_line_form').find('.credit').val('0.00');
  } else {
    $(this).closest('.writing_line_form').find('.debit').val('0.00');
  }
}


// Objectif : avoir une icone plus à côté des forms de compta_line pour
// pouvoir ajouter des lignes. Problème : l'icone étant dans le partial,
// il est difficile de ne pas créér une récurrence.
// On s'appuie donc sur un lien hors formulaire mais caché
jQuery(function() {
  // on s'assure que le lien ajout est masqué'
  //$('.compta_writings #add_line_link').hide();
  // mettre le focus sur le champ date
  $('.compta_writings input#writing_date_picker').change(function() {
    document.getElementById("writing_narration").focus(true);
  });

  $('.compta_writings a.add_form_line img').hide();
//    $('.compta_writings a.add_form_line img').unbind('click');
  $('.compta_writings .writing_line_form:visible:last a.add_form_line img').show();

  if ($('.compta_writings').size() > 0) {
    $('.compta_writings a.add_form_line img').hide();
    $('.compta_writings .writing_line_form:visible:last a.add_form_line img').show();
    $check_submit();
  }
  // $check_submit masque le bouton submit si les conditions ne sont pas remplies
  // conditions 1: au moins une ligne remplie
  // condition 2 : écriture équilibrée
  $('.compta_writings').on('change', 'input.decimal', $zero_field); // calcule le nouvau solde et l'affiche
  $('.compta_writings').on('change', 'input.decimal', $check_submit); // calcule le nouvau solde et l'affiche
  // enfin, on attache les évènements aux boutons des lignes
  $('a.remove_form_line').on('click', $remove_writing_line_form);
  $('.compta_writings .writing_line_form:visible:last a.add_form_line').on('click', $deal_icon_plus);


});
