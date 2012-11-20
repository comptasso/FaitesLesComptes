# coding: utf-8

module Utilities

  module ToCsv

    def to_xls(options = {col_sep:"\t"})
      to_csv(options).encode("windows-1252")
    end

    private

    def to_csv(options = {col_sep:"\t"})
      raise NotImplemented, 'Vous devez implémentez cette méthode dans la classe dans laquelle vous incluez ce module'
    end
  end
end
