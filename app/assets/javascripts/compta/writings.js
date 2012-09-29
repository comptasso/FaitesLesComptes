"use strict";

var $, jQuery;

// On cache tous les sigles plus sauf celui de la dernière ligne
// puis on relie le click de cette image au lien qui ajoute la ligne
//
function $deal_icon_plus() {
    $('.compta_writings a.add_form_line img').hide();
    $('.compta_writings a.add_form_line img').unbind('click');
    $('.compta_writings .writing_line_form:visible:last a.add_form_line img').show();
    $('.compta_writings .writing_line_form:visible:last a.add_form_line img').click(function () {
        $('#add_line_link a').click();
    });
}

// renvoie le total correspondant au selector mais seulement pour les lignes
// visibles.
function $total_sel(selector) {
    var t = 0;
    $(selector).each(function (index) {
        if ($(this).closest('.writing_line_form').is(':visible')) {
            t = t + parseFloat($(this).val(), 10);
        }
    });
    return t;
}

function $balance() {
    return $total_sel('.credit') - $total_sel('.debit');
}



// fait la somme des débit et la somme des credits et retourne un booleen indiquant l'égalité
function $balanced() {
    if ($total_sel('.debit') === $total_sel('.credit')) {
        return true;
    } else {
        return false;
    }
}

// retourne le nombre de lignes qui au soit débit soit credit de rempli
function $nb_lines() {
    var i = 0;
    $('.compta_writings .writing_line_form').each(function (index) {
        if (($(this).find('.debit:first').val() !== '0.00') ||  ($(this).find('.credit:first').val() !== '0.00')) {
            i = i + 1;
        }

    });
    return i;
}

function $check_submit() {
    var bal = $balanced(), nb_lines = $nb_lines();
    if ((bal === true) && (nb_lines > 1)) {
        $('input.btn').show();
    } else {
        $('input.btn').hide();
    }
}

// retire une compta_line du formulaire ou plutôt la cache
function remove_writing_line_form(link) {
    var wlf = $(link).closest(".writing_line_form"), last = false;
    // wlf est-elle la dernière ligne visible ?
    if ($('.writing_line_form:visible:last').is(wlf)) {
        last = true;
    }
    $(link).prev("input[type=hidden]").val("1");
    wlf.hide();
    // on masque ou affiche l'icone plus qui convient
    $deal_icon_plus();
    // on vérifie que l'on peut afficher le bouton submit
    $check_submit();
}

// ajoute les champs pour une compta_line supplémentaire dans le formulaire
// voir railscasts#197
// new_id est calculé sur le temps pour avoir un chiffre unique
// perso, j'aurai plutôt compté les lignes mais je laisse comme ça
function add_fields(link, association, content) {
    var new_id = new Date().getTime(), regexp = new RegExp("new_" + association, "g");
    $(link).parent().before(content.replace(regexp, new_id));
    $deal_icon_plus();
}


// Objectif : avoir une icone plus à côté des forms de compta_line pour
// pouvoir ajouter des lignes. Problème : l'icone étant dans le partial,
// il est difficile de ne pas créér une récurrence.
// On s'appuie donc sur un lien hors formulaire mais caché
jQuery(function () {
    // on s'assure que le lien ajout est masqué'
    $('.compta_writings #add_line_link').hide();
    if ($('.compta_writings').size() > 0) {
        $deal_icon_plus();
    }
    // $check_submit masque le bouton submit si les conditions ne sont pas remplies
    // conditions 1: au moins une ligne remplie
    // condition 2 : écriture équilibrée
    $('.compta_writings input.decimal').live('change', $check_submit); // calcule le nouvau solde et l'affiche

});
