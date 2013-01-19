# coding: utf-8
require 'pdf_document/book'

module PdfDocument

  # Classe destinée à imprimer un livre ou un extrait de livre en format pdf
  #
  # Cette classe hérite de PdfDocument::Default et surcharge fetch_lines
  class Cash < PdfDocument::Book
      # period est un exercice,
    # source est un record, par exemple Account
    # select_method est une méthode pour donner la collection, par defaut comptpa_lines
#    def initialize(period, arel, options)
#      @title = options[:title]
#      @subtitle = options[:subtitle]
#      @period = period
#      @from_date = options[:from_date] || @period.start_date
#      @to_date = options[:to_date] || @period.close_date
#      @nb_lines_per_page = options[:nb_lines_per_page] || NB_PER_PAGE_LANDSCAPE
#      @source = arel
#      @stamp = options[:stamp]
#      @created_at = Time.now
#      @select_method = options[:select_method] || 'compta_lines'
#    end

    # renvoie les lignes de la page demandées
    def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      @source.compta_lines.select(columns).extract(from_date, to_date).offset(offset).limit(limit)
    end

    # appelle les méthodes adéquate pour chacun des éléments de la lignes
    # le rescue nil permet de ne pas générer une erreur si un champ composé n'est
    # pas présent.
    # Par exemple nature.name lorsque nature est nil
    def prepare_line(line)
      pl = columns_methods.collect { |m| line.instance_eval(m) rescue nil }
      pl[0] = I18n::l(pl[0]) rescue 'date error'
      pl
    end
  end

end
