

  jQuery(function() {
    function _fnAlert(message, type) {alert(message);}

    function fnChangeValue(element, new_value) {
       element.attr('data-position', new_value);
       element.find('td:first-child').text(new_value);
    }

    function fnMoveRows(from, to) {
      iFrom = parseInt(from);
      iTo = parseInt(to);
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

// appelée par ajax en cas d'erreur
    function fnCancelSorting(tbody, sMessage) {
			tbody.sortable('cancel');
				if(sMessage!= undefined){
					_fnAlert(sMessage, "");
				}else{
					_fnAlert("Row cannot be moved", "");
				}
        }

    $('#ltps').sortable({
      connectWith: ".connectedSortable",
      items: "tr"
    });


    $( "#bels" ).sortable({
      connectWith: ".connectedSortable",
      items: "tr",
      // limter l appel de update au cas d un tri dans la même liste
      // et utiliser remove et receive pour traiter les autres cas
      update: function(event, ui) {
        var tbody = $(this);
        var id = ui.item.context.id;
     //   $('h3').text(ui.item.context.classList[0]);
        
        // la logique est la suivante : data-position donne la position initiale de la ligne
        // après un déplacement data-position est du coup le numéro de ligne d'origine
        var from = $("#" + id).attr('data-position');
        // il faut donc trouver à quelle place se trouve le drop
        // chercher quel est le rang en balayant les lignes
        var to = -1;
        $('tr').each(function(index){
          if ($(this).attr('id') == parseInt(id)) {
            to = index;
          }

        });

        // il faut remplacer pointage par reorder

        $.ajax({
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
    }).disableSelection();
  });

  




