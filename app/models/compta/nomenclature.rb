# coding: utf-8

module Compta
  class Nomenclature

    include ActiveModel::Validations 


    validates :exploitation, :actif, :passif, :presence=>true

    def initialize(yml_file)
      path = case Rails.env
      when 'test' then File.join Rails.root, 'spec', 'fixtures', 'nomenclatures', yml_file
      else
        File.join Rails.root, 'app', 'assets', 'parametres', 'asso', yml_file 
      end
      @documents = YAML::load_file(path)

    end

    def document(page)
      @documents[page]
    end

    def exploitation
      @documents[:exploitation]
    end

    def actif
      @documents[:actif]
    end

    def passif
      @documents[:passif]
    end

    # vérifie que tous les comptes sont pris en compte pour l'établissement du bilan
    def bilan_complete?(period)
      list_accs = period.two_period_account_numbers # on a la liste des comptes
      rubrik_accs = []
      actif[:rubriks].each {|r| rubrik_accs += r.list_numbers}
      passif[:rubriks].each {|r| rubrik_accs += r.list_numbers}
      not_selected =  list_accs.select {|a| !a.in? rubrik_accs}
      not_selected.empty? ? true : false 
    end




    
  end
end
