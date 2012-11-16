# coding: utf-8

module Compta
  class Nomenclature

    include ActiveModel::Validations 


    validates :exploitation, :actif, :passif, :presence=>true
    validate :bilan_complete, :bilan_balanced, :resultats_67


    def initialize(period, yml_file)
      @period = period
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

    def bilan_complete?
      bilan_complete.empty? ? true : false
    end

    # vérifie que tous les comptes sont pris en compte pour l'établissement du bilan
    # à l'exception des comptes de classes 8 qui servent à valoriser le bénévolat
    def bilan_complete
      list_accs = @period.two_period_account_numbers # on a la liste des comptes
      rubrik_accs = []
      rubrik_accs += numbers_from_document(:actif) + numbers_from_document(:passif)
      not_selected =  list_accs.select {|a| !a.in?(rubrik_accs) && !(a=~/^8\d*$/) }
      unless not_selected.empty?
        self.errors[:bilan] << "Tous les comptes ne sons pas repris pour l\'édition du bilan. Comptes non trouvés : #{not_selected.join(', ')}"
      end
      return not_selected
    end


    # sert à vérifier que si on compte C est pris, on trouve également un compte D
    # et vice_versa.
    # Ajoute une erreur à :bilan si c'est le cas avec comme message la liste des comptes
    # qui n'ont pas de correspondant
    def bilan_balanced
      numbers = ''
      numbers += rough_accounts_list(:actif) + rough_accounts_list(:passif) 
      array_numbers = numbers.split
      # maintenant on crée une liste des comptes D et une liste des comptes C
      numbers_d = array_numbers.map {|n| $1 if n =~ /^(\d*)D$/}.compact.sort
      numbers_c = array_numbers.map {|n| $1 if n =~ /^(\d*)C$/}.compact.sort
    
      if numbers_d == numbers_c
        return true
      else
        d_no_c = numbers_d.reject {|n| n.in? numbers_c}
        c_no_d = numbers_c.reject {|n| n.in? numbers_d}
        
        self.errors[:bilan] << "Comptes D sans comptes C correspondant: #{d_no_c.join(', ')}" unless d_no_c.empty?
        self.errors[:bilan] << "Comptes C sans comptes D correspondant: #{c_no_d.join(', ')}" unless c_no_d.empty?
        
        return false
      end
    end

    # sert à contrôler que les différentes rubriques de resultats n'utilisent que des comptes 6 et 7
    def resultats_67
      nf = numbers_from_document(:exploitation)
      r = include_only(nf, 6, 7)
      unless r.empty?
        self.errors[:exploitation] << "La partie Exploitation comprend un compte étranger aux classes 6 et 7 : #{r.join(', ')}"
        return false
      else
        return true
      end
    end

    protected

    # vérifie que les numéros de comptes ne comprennent que les comptes qui commencent pas *args
    # par exemple include_only(%w(701, 603, 407), 6, 7)
    def include_only(list_numbers, *args)
      args.each do |a|
        list_numbers.select! {|n| n !~ /^#{a}\d*/}
      end
      list_numbers
    end



    

    def rough_accounts_list(doc)
      list = ''
      @documents[doc][:rubriks].each {|k,v| v.each { |t, accs| list += ' ' + accs } }
      list
    end

    # doc est un symbol comme :actif ou :passif
    def numbers_from_document(doc)
      numbers = []
      @documents[doc][:rubriks].each {|k,v| v.each { |t, accs| numbers += Compta::RubrikParser.new(@period, :actif, accs).list_numbers } }
      numbers
    end

    



    
  end
end
