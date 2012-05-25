

jQuery(function() {
  function _fnAlert(message, type) {
    alert(message);
  }

  function fnChangeValue(element, new_value) {
    element.attr('data-position', new_value);
    element.find('td:first-child').text(new_value);
  }

  function fnMoveRows(from, to) {
    var iFrom = parseInt(from);
    var iTo = parseInt(to);
    var pos;
    // par exemple, je passe la ligne 2 à la ligne 6,
    if (iTo > iFrom) {
    $('#bels tr').each(function(index){
        pos = parseInt($(this).attr('data-position'));
        // et la ligne 2 devient la ligne 6
        if (pos == iFrom) {
          fnChangeValue($(this), iTo.toString());
        }
        // les lignes 3 à 6 perdent 1 cran
        if (pos > iFrom && pos <= iTo) {
          fnChangeValue($(this), (pos-1).toString());
        }
      });
    }
    //dans l'autre sens, je passe de la ligne 6 à la ligne 2'
    // donc iFrom = 6 et iTo = 2
    if (iTo < iFrom) {
      $('#bels tr').each(function(index){
        pos = parseInt($(this).attr('data-position'));
        // et la ligne 6 devient la ligne 2
        if (pos == iFrom) {
          fnChangeValue($(this), iTo.toString());
        }

        // les lignes 2 à 5 gagnent 1 cran
        if (pos >= iTo && pos < iFrom) {
          fnChangeValue($(this), (parseInt(pos)+1).toString());
        }
      });
    }

  }

  //appelée après avoir enlevé une ligne
  // on retire donc 1 pour chacun des lignes qui se trouvait après celle qu'on a retiré
  function fnDecRows(from) {
    var iFrom = parseInt(from);
    $('#bels tr').each( function(index){
        pos = parseInt($(this).attr('data-position'));
         if (pos > iFrom) {
          fnChangeValue($(this), (parseInt(pos)-1).toString());
        }
    });
  }

  function fnIncRows(from) {
    var iFrom = parseInt(from);
    $('#bels tr').each( function(index){
        pos = parseInt($(this).attr('data-position'));
         if (pos >= iFrom) {
          fnChangeValue($(this), (parseInt(pos)+1).toString());
        }
    });
  }

  // appelée par ajax en cas d'erreur
  function fnCancelSorting(tbody, sMessage) {
    tbody.sortable('cancel');
    if(sMessage!= undefined){
      _fnAlert(sMessage, "");
    }else{
      _fnAlert("La ligne n'a pas pu être déplacée", "");
    }
  }

  function fnCheckTotalDebit(){
    if ($('#bels_total_debit').text() === $('#total_debit').text()) {
      $('#img_danger_total_debit').hide();
    }
    else {
      $('#img_danger_total_debit').show();
    }
  }

  function fnCheckTotalCredit(){
    if ($('#bels_total_credit').text() === $('#total_credit').text()) {
      $('#img_danger_total_credit').hide();
    }
    else {
      $('#img_danger_total_credit').show();
    }
  }

  // AFFICHAGE DES POPOVERS
   $('img[alt="Detail"]').popover();

  // AFFICHER OU MASQUER LES PANNEAUX DANGER A L AFFICHAGE DE LA PAGE
  // la mise à jour est faite par le traitement de la réponse du controller
  // aux actions remove et insert
  fnCheckTotalDebit();
  fnCheckTotalCredit();
 
  // lorsque le total crédit change, appel de fnCheckTotalCredit
  // $('#bels_total_credit').onChange()


  // LA TABLE DES LTPS 5LINES TO POINT)
  $('#ltps').sortable({
    connectWith: ".connectedSortable",
    items: "tr"
  });

  // LA TABLE DES BELS
  $( "#bels" ).sortable({
    connectWith: ".connectedSortable",
    items: "tr",
    
    // lorsqu'on ajoute un membre à la table, il faut envoyer une action
    // insert en indiquant l'id comme params
    receive: function(event, ui) {
      
      var place = -1;
      var id = ui.item.context.id;
      var siblings = $("#" + id + ' ~ tr') // fonction qui trouve les suivants
      // #0 est une ligne utilisée pour indiquer qu'on peut faire un drag and drop
      // si elle est là, la position est forcément la première.
      if ($('#bels #0').length === 1) {
        place = 1;
      }
      else if (siblings.length === 0) {
        // c'est le dernier de la liste donc on
        // prend la longueur de la liste
        place = $('#bels tr').length
      }
      else {
       // sinon on prend la position du premier suivant
       place =  $(siblings[0]).attr('data-position')
      }

     
      $.ajax({
        url: window.location.pathname.replace('pointage', id.toString() + '/insert'),
        type: 'post',
        data: {
          html_id: id,
          at: place
        },
        success: function() {
//          fnCheckTotalDebit();
//          fnCheckTotalCredit();
        },
        
        // ou inversement on annule si erreur
        error: function (jqXHR) {
          fnCancelSorting(ui.sender, jqXHR.statusText);
        }
      })
    },

    // lorsqu'on retire un membre de la table, il faut
    // noter sa position, faire une requête ajax pour le supprimer de
    // la base de données,
    // et insérer une réponse dans la table d'arrivée au bon endroit
    // ou redessiner la table d'arrivée'
    remove: function(event, ui) {

      // $('h3').text('remove en action');
      
      var id = ui.item.context.id;
      var from = $("#" + id).attr('data-position');
      $.ajax({
        url: window.location.pathname.replace('pointage', id.toString() + '/remove'),
        type: 'post',
        data: {
          id: id
        },
        success: function() {
//          fnCheckTotalDebit();
//          fnCheckTotalCredit();
        },
        // on annule si erreur
        error: function (jqXHR) {
          fnCancelSorting(ui.sender, jqXHR.statusText);
        }
      })
    },

    //callback utilisée pour le changement d'emplacement à l'intérieur de la table
    // des bank_extract_lines. On ne doit pas appeler update pour les
    // transferts d'une table à l'autre doù la nécessité d'un filtre
    update: function(event, ui) {

      var tbody = $('#bels');
      var id = ui.item.context.id;
      // les id des bels sont constituées uniquement de l'id de la BankExtractLine'
      
      if (ui.sender === null) {
        // la logique est la suivante : data-position donne la position initiale de la ligne
        // après un déplacement data-position est du coup le numéro de ligne d'origine
        var from = $("#" + id).attr('data-position');
        // il faut donc trouver à quelle place se trouve le drop
        // chercher quel est le rang en balayant les lignes
        var to = -1;
        $('#bels tr').each(function(index){
          if ($(this).attr('id') == parseInt(id)) {
            to = index +1;
          }

        });
       
        $.ajax({
          // il faut remplacer pointage par reorder
          url: window.location.pathname.replace('pointage', 'reorder'),
          type: 'post',
          data: {
            id: id,
            fromPosition: from,
            toPosition: to
          },
          // puis on fait la mise à jour des données de la table
          success: function () {
            fnMoveRows(from, to);
          },
          // ou inversement on annule si erreur
          error: function (jqXHR) {
            fnCancelSorting(tbody, jqXHR.statusText);
          }
        });
      
      }

    }
  }).disableSelection();
});

  




