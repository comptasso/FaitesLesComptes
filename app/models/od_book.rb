# coding: utf-8

class OdBook < Book

  has_many :transfers, :dependent=>:destroy, :foreign_key=>'book_id'

  # nécessaire car la vue line affiche les comptes en fonction de income_outcome
  # TODO probablement à faire évoluer lors de la refonte du formulaire line pour
  # la partie compta
  def income_outcome
    true
  end

end
