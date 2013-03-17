# coding: utf-8
require 'pdf_document/default'

module PdfDocument

  # Classe destinée à imprimer un livre ou un extrait de livre en format pdf
  #
  # Cette classe hérite de PdfDocument::Default et surcharge fetch_lines
  class Book < PdfDocument::Default

    # renvoie les lignes de la page demandées
    def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      @source.compta_lines.select(columns).extract(from_date, to_date).in_out_lines.offset(offset).limit(limit)
    end

    # calcule de nombre de pages; il y a toujours au moins une page
    # même s'il n'y a pas de lignes dans le comptes
    # ne serait-ce que pour afficher les soldes en début et en fin de période
    def nb_pages
      nb_lines = @source.compta_lines.extract(from_date, to_date).in_out_lines.count
      return 1 if nb_lines == 0
      (nb_lines/@nb_lines_per_page.to_f).ceil
    end


    # la méthode support n'est pas directement accessible par les tables
    # donc on utilise l'id récupéré pour appelé la fonction support.
    # Une autre option possible serait d'enregistrer cette info dans la table
    # pour en faciliter la restitution. 
    # 
    # Ne pas confondre ce prepare_line pour le pdf avec celui qui est dans 
    # InOutExtract et qui est pour l'export vers excel ou csv
    # 
    # TODO : traiter ce sujet en fonction des performances 
    def prepare_line(line)
      pl = columns_methods.collect { |m| line.instance_eval(m) rescue nil }
      pl[0] = I18n::l(Date.parse(pl[0])) rescue pl[0]
      w=Writing.find_by_id(pl.last)
      pl[-1] = w.support # récupération du support
      pl[-2] = w.payment_mode
      pl
    end

    

  end
end
