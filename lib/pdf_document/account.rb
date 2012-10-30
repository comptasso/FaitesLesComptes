# coding: utf-8

require 'pdf_document/default.rb'
  require 'pdf_document/page.rb'
module PdfDocument

  class Account < PdfDocument::Default

 
    def prepare_line(line)
      [I18n::l(Date.parse(line.w_date)), line.b_title, line.w_ref, line.w_narration, (line.nature ? line.nature.name  : ''),
         (line.destination ? line.destination.name  : ''),
      '%0.2f' % line.debit, '%0.2f' % line.credit]
    end

    # renvoie les lignes de la page demandées
    # Account ne prend pas en compte les lignes d'à nouveau dans la liste des écritures
    # mais le prend dans le solde d'ouverture 
    def fetch_lines(page_number)
      limit = nb_lines_per_page
      offset = (page_number - 1)*nb_lines_per_page
      @source.compta_lines.with_writing_and_book.select(columns).without_AN.range_date(from_date, to_date).offset(offset).limit(limit)
    end


  end
end