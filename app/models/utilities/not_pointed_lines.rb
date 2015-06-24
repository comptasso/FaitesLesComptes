# coding: utf-8

module Utilities


  # Cette classe est une collection des lignes non pointées pour un compte bancaire spécifique
  #
  # Se crée par new avec un compte bancaire comme argument
  #
  # La liste des écritures non pointées est stockée sous forme de tableau de hash
  # reprenant les infos nécessaires à l'affichage dans l'action pointage
  #
  # A savoir le type d'écriture par un symbole (:check_deposit ou :standard_line)
  # la date, un libéllé qui peut être Remise de chèque ou narration,
  # le débit et le crédit
  #
  class NotPointedLines

    attr_reader :lines, :bank_account

    def initialize(bank_account, before_date = nil)
      @bank_account = bank_account
      fetch_lines(before_date) 
    end
    
    # permet d'itérer les lignes et d'effectuer l'action fournie par le block 
    def each_line
      raise ArgumentError, "Un bloc est nécessaire" unless block_given?
      lines.each {|l| yield l}
    end

    def size
      lines.count
    end

    def total_debit
      lines.sum(&:debit)
    end

    def total_credit
      lines.sum(&:credit)
    end

    def sold
      total_credit - total_debit
    end
    
    

    private
    
     def fetch_lines(before_date)
      @lines ||= set_lines(before_date) 
    end

    # permet de limiter les écritures retournées à celles qui sont antérieures
    # à une date.
    #
    # Cela est utile pour ne pas afficher des lignes de 2014, alors qu'on est 
    # en train de traiter la clôture de 2013 et qu'on veut vérifier qu'il n'y a 
    # plus de ligne à pointer pour cet exercice.
    def set_lines(before_date)
      ls = bank_account.compta_lines.not_pointed 
      ls = ls.where('writings.date <= ?', before_date) if before_date
      ls.to_a
    end
    
   
    
  end



end
