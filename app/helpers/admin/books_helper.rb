# coding: utf-8
module Admin::BooksHelper
  def jc_url(organism, book)
    book.new_record? ? admin_organism_books_path(organism) :  admin_organism_book_path(organism,book)
  end

  def jc_method(book)
    book.new_record? ? :post : :put
  end


end
