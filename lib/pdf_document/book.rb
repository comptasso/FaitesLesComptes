# coding: utf-8
require 'pdf_document/default'

module PdfDocument

  # Classe destinée à imprimer un livre ou un extrait de livre en format pdf
  # cette classe surcharge fetch_lines
  class Book < PdfDocument::Default
    # renvoie les lignes de la page demandées
    def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      @source.compta_lines.select(columns).mois(from_date).offset(offset).limit(limit)
    end



    # calcule de nombre de pages; il y a toujours au moins une page
    # même s'il n'y a pas de lignes dans le comptes
    # ne serait-ce que pour afficher les soldes en début et en fin de période
    def nb_pages
      nb_lines = @source.compta_lines.mois(from_date).count
      return 1 if nb_lines == 0
      (nb_lines/@nb_lines_per_page.to_f).ceil
    end

  end
end
