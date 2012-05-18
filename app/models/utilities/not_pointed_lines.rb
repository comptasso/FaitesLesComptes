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

  class NotPointedLines

    attr_reader :list

    def initialize(bank_account)
      @list = []
      @bank_account = bank_account
      fill_np_check_deposits
      fill_np_lines
    end

    private

    def fill_np_check_deposits
      # Trouve toutes les remises de chèques qui ne sont pas encore pointées
      @bank_account.check_deposits.where('bank_extract_id IS NULL').each do |cd|
        @list << { :nature=> :check_deposit,
          date:cd.deposit_date,
          narration:'Remise de chèque',
          debit:0,
          credit:cd.total_checks
        }
      end
    end

    def fill_np_lines
      @bank_account.np_lines.each do |l|
        @list <<   { :nature=> :standard_line,
          date:l.line_date,
          narration:l.narration,
          debit:l.debit,
          credit:l.credit
        }

      end
    end



    

  end



end
