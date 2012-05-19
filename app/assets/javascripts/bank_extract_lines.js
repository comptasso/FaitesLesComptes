

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
      _fnAlert("Row cannot be moved", "");
    }
  }

  function fnInsertTd(row_id, value){
    $(row_id + ' td').first().before('<td>' + value + '</td>');
    
  }

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
      var tbody = $('#bels');
      var place = -1;
      var id = ui.item.context.id;
      var siblings = $("#" + id + ' ~ tr')
      if (siblings.length === 0) {
        place = $('#bels tr').length
      }
      else {
       place =  $(siblings[0]).attr('data-position')
      }

     
      $.ajax({
        url: window.location.pathname.replace('pointage', 'insert'),
        type: 'post',
        data: {
          html_id: id,
          at: place
        },
        // puis on fait la mise à jour des données de la table
        success: function (data, txt, jqXhr) {
          $("#" + id ).removeClass('ltp').
            addClass('bel').
            attr('data-position', place.toString());
          $('h3').text(place.toString() );
          // ajouter un td en début du contenu et retirer le dernier td
          fnInsertTd('#' + id, '<td>' + place + '</td>');
          fnIncRows(parseInt(place) + 1);
        },
        // ou inversement on annule si erreur
        error: function (jqXHR) {
          fnCancelSorting(tbody, jqXHR.statusText);
        }
      })
    },

    // lorsqu'on retire un membre de la table, il faut
    // noter sa position, faire une requête ajax pour le supprimer de
    // la base de données,
    // et insérer une réponse dans la table d'arrivée au bon endroit
    // ou redessiner la table d'arrivée'
    remove: function(event, ui) {

      $('h3').text('remove en action');
      var tbody = $(this);
      var id = ui.item.context.id;
      var from = $("#" + id).attr('data-position');
      $.ajax({
        url: window.location.pathname.replace('pointage', 'remove'),
        type: 'post',
        data: {
          id: id
        },
        // puis on fait la mise à jour des données de la table
        success: function () {
          fnDecRows(from);

        },
        // ou inversement on annule si erreur
        error: function (jqXHR) {
          fnCancelSorting(tbody, jqXHR.statusText);
        }
      })
    },

    //callback utilisée pour le changement d'emplacement à l'intérieur de la table
    // des bank_extract_lines. On ne doit pas appeler update pour les
    // transferts d'une table à l'autre doù la nécessité d'un filtre
    update: function(event, ui) {

      var tbody = $(this);
      var id = ui.item.context.id;
      // les id des bels sont constituées uniquement de l'id de la BankExtractLine'
      var matching = id.match(/^\d+$/)
      if (matching != null) {
        //   $('h3').text(ui.item.context.classList[0]);
        $('h3').text('update en action');
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

        // Si to est différent de -1, c'est qu'on a déplacé la bel
        // dans la table des bel donc on fait la mise à jour par reorder
        if (to != -1) {
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

    }
  }).disableSelection();
});

  




