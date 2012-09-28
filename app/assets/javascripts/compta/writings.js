// retire une compta_line du formulaire ou plutôt la cache
function remove_writing_line_form(link) {
        $(link).prev("input[type=hidden]").val("1");
        $(link).closest(".writing_line_form").hide();
}

// ajoute les champs pour une compta_line supplémentaire dans le formulaire
// voir railscasts#197
// new_id est calculé sur le temps pour avoir un chiffre unique
// perso, j'aurai plutôt compté les lignes mais je laisse comme ça
function add_fields(link, association, content) {
        var new_id = new Date().getTime();
        var regexp = new RegExp("new_" + association, "g");
        $(link).parent().before(content.replace(regexp, new_id));
        hide_nouveau();


       
}

function hide_nouveau() {
  $('.compta_writings a.add_form_line img').hide();
  $('.compta_writings a.add_form_line img:last').show();
  $('.compta_writings a.add_form_line img').click(function(){
    $('#add_line_link a').click();
  });
}


jQuery(function () {
  $('.compta_writings #add_line_link').hide();
  if ($('.compta_writings').size() > 0) { hide_nouveau();}
});
