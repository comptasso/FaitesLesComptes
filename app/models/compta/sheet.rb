# coding: utf-8

# Sheet doit être capable de lister les informations pour faire une édition des comptes
# regroupés  
#
require 'yaml'

module Compta
  class Sheet

    def initialize(period, template)
      @period = period
      @rubriks = YAML::load_file(File.join Rails.root, 'lib', 'templates', 'sheets', template)
    end

    def render
      tableau = []
       @rubriks.each do |rubrik|
         r = Compta::Rubrik.new(@period, rubrik[:title], rubrik[:numeros])
         tableau << [rubrik[:title]]
         tableau += r.values
         tableau << r.totals
       end
       tableau
    end

  end

end