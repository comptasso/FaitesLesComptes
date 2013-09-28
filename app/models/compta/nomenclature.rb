# coding: utf-8

module Compta





  # Permet de produire les différents documents de la liasse : actif, passif,
  # résultats et bénévolat.
  #
  # Le modèle inclut le module Validations, ce qui permet de vérifier qu'au minimum
  # :actif, :passif et :resultat sont présents. Seul :benevolat est optionnel.
  #
  # Par ailleurs, une autre série de validation vérifie
  # * que le bilan est complet et qu'il est balancé (c'est à dire que tout compte D a un compte C correspondant)
  # * que le compte de résultats est complet et qu'il n'utilise que les comptes 6 et 7
  # * que le bénévolat n'utilise que des comptes 8
  # * qu'auncun compte n'est pris en double, mais que tous les comptes sont utilisés
  #
  # Une nomenclature se crée avec deux arguments, un exercice et un fichier au format yml;
  #
  # Par défaut, le fichier est 'nomenclature.yml' et se situe dans le répertoire
  # app/assets/parametres/(association|entreprise)/nomenclature.yml
  #
  class Nomenclature

    include ActiveModel::Validations

    attr_accessor :instructions

    # permet de définir l'ensemble des méthodes d'accès aux pages (:actif, :passif, ...
    # voir juste dessous l'utilisation
    def self.def_doc(*args)
      args.each do |a|
        define_method a do
          instructions[a]
        end
      end
    end

    # Déclaration des documents disponibles.
    #
    # On accède aux documents par un array : instructions[:document] 
    def_doc :resultat, :actif, :passif, :benevolat

    validates :actif, :passif, :resultat, :presence=>true
    validate :bilan_complete, :bilan_balanced, :resultats_67, :resultat_complete,
      :benevolat_8, :no_doublon?



    # initialize peut se faire à partir d'un exercice et d'un hash.
    #
    # En pratique, une nomenclature se crée par l'exercice qui demande la nomenclature
    # de l'organisme
    #
    # instructions est un fichier yml qui définit la construction de la nomenclature
    #
    def initialize(period, instructions)
      @period = period
      @instructions = instructions
    end

     # renvoie la liste des pages existant dans cette nomenclature
      def pages
        @instructions.map {|k, v| k}
      end
      
        
    # renvoie une page, par exemple :actif ou :passif, ou :bilan sous forme d'une
    # instance de Compta::Sheet
      def sheet(doc)
        Compta::Sheet.new(@period, @instructions[doc], doc) if @instructions[doc]
      end


      # no_doublon vérifie que la nomenclature ne prend pas deux fois le même compte
      # pour chacun des éléments : :actif, :passif, :resultat, :benevolat
      #
      def no_doublon?
        pages.each {|p| doc_no_doublon?(p) }
        collection_with_option_no_doublon?(:bilan, :actif, :passif)
      end

      # Cherche les doublons en prenant en compte le fait que les comptes standard (ceux avec nil comme :option
      # ne sont pas déjà pris dans les comptes avec option[:col_2], ce qui pour mémoire, signifie qu'ils sont 
      # retenus en tant qu'amortissement ou provision (deuxième colonne pour les documents actifs)
      # 
      # On effectue le même traitement avec les comptes qui ont nil et les comptes qui ont crédit comme option
      # 
      # Puis enfin avec les comptes qui ont nil et les comptes qui ont débit.
      #
      # Le premier argument servira comme nom pour enregistrer l'erreur s'il y en a une
      # le deuxième argument est une liste de documents à regrouper pour tester l'existence
      # de ces doublons : par exemple pour un bilan : [:actif, :passif].
      #
      # Ainsi collection_with_option_no_doublon?(:bilan, :actif, :passif) recherche les doublons dans
      # les documentsw :actif et :passif et ajoute une erreur sur :bilan s'il y en a
      #
      def collection_with_option_no_doublon?(name, *docs)
        numbers = collection_numbers_with_option(*docs)
        dup = []
        # on doit vérifier que les nil et les col2 n'ont aucun doublon
        list = numbers.select {|o| o[:option] == nil || o[:option] == :col2}.map {|n| n[:num]}
        dup += doublon_in_list(list)
      
        # on n'accepte pas non plus des doublons entre les nil col2 et les credit d'un côté, les débit de l'autre
        # les comptes de crédit ne peuvent être dans list
        n_credit = numbers.select {|n| n[:option] == :credit}.map {|n| n[:num]}
        dup +=  (n_credit & list) # intersection avec list
        dup += doublon_in_list(n_credit)
        # les comptes de débit ne peuvent être dans list
        n_debit = numbers.select {|n| n[:option] == :credit}.map {|n| n[:num]}
        dup += (n_debit & list) # intersection avec list
        dup += doublon_in_list(n_debit)
        self.errors[name] << "comprend des doublons (#{dup.uniq.join(', ')})" unless dup.empty?
      end

      # Teste la présence de doublons dans un document
      def doc_no_doublon?(doc)
        dil = doublon_in_list(numbers_from_document(doc))
        unless dil.empty?
          Rails.logger.info "#{doc} comprend un compte en double (#{dil.join(', ')})"
          self.errors[doc] << "comprend des doublons (#{dil.join(', ')})"
          return false
        end
        true
      end

      # Indique si le document bilan utilise tous les comptes de bilan
      def bilan_complete?
        bilan_complete.empty? ? true : false
      end

     

     


      protected

      

      # vérifie que tous les comptes sont pris en compte pour l'établissement du bilan
      # à l'exception des comptes de classes 8 qui servent à valoriser le bénévolat
      def bilan_complete
        list_accs = @period.two_period_account_numbers # on a la liste des comptes
        rubrik_accs = []
        rubrik_accs += numbers_from_document(:actif) + numbers_from_document(:passif)
        not_selected =  list_accs.select {|a| !a.in?(rubrik_accs) && !(a=~/^8\d*$/) }
        unless not_selected.empty?
          self.errors[:bilan] << "ne reprend pas tous les comptes. Manque #{not_selected.join(', ')}"
        end
        return not_selected
      end

      # vérifie que tous les comptes 6 et 7 sont pris en compte pour l'établissement du compte de résultats 
      def resultat_complete
        list_accs = rough_accounts_reject(@period.two_period_account_numbers, 1,2,3,4,5,8)
        rubrik_accounts = numbers_from_document(:resultat)
        not_selected =  list_accs.select {|a| !a.in?(rubrik_accounts) }
        self.errors[:resultat] << "Le compte de résultats ne reprend pas tous les comptes 6 et 7. Manque #{not_selected.join(', ')}" if not_selected.any?
      end

   

      # sert à vérifier que si on compte C est pris, on trouve également un compte D
      # et vice_versa.
      # Ajoute une erreur à :bilan si c'est le cas avec comme message la liste des comptes
      # qui n'ont pas de correspondant
      def bilan_balanced
      
        array_numbers = rough_accounts_list(:actif) + rough_accounts_list(:passif)
      
        # maintenant on crée une liste des comptes D et une liste des comptes C
        numbers_d = array_numbers.map {|n| $1 if n =~ /^(\d*)D$/}.compact.sort
        numbers_c = array_numbers.map {|n| $1 if n =~ /^(\d*)C$/}.compact.sort
    
        if numbers_d == numbers_c
          return true
        else
          d_no_c = numbers_d.reject {|n| n.in? numbers_c}
          c_no_d = numbers_c.reject {|n| n.in? numbers_d}
        
          self.errors[:bilan] << " : comptes D sans comptes C correspondant (#{d_no_c.join(', ')})" unless d_no_c.empty?
          self.errors[:bilan] << " : comptes C sans comptes D correspondant (#{c_no_d.join(', ')})" unless c_no_d.empty?
        
          return false
        end
      end

      # sert à contrôler que les différentes rubriques de resultats n'utilisent que des comptes 6 et 7
      def resultats_67
        retour = true
        [:exploitation, :financier, :exceptionnel].each do |partie|
          r = rough_accounts_reject(rough_accounts_list(partie), 6, 7)
          unless r.empty?
            self.errors[partie] << "comprend un compte étranger aux classes 6 et 7 (#{r.join(', ')})"
            retour = false
          end
        end
        retour
      end

      # controle que le bénévolat ne comprend que des comptes de classe 8
      def benevolat_8
        unless  (r = rough_accounts_reject(rough_accounts_list(:benevolat), 8)).empty?
          self.errors[:benevolat] << "comprend un compte étranger à la classe 8 (#{r.join(', ')})"
          return false
        end
        true
      end


    

      # A partir d'un array numbers ne garde que les nombres commencent par
      # les chiffres donnés par args.
      # Utilisé par resultat_67 et benevolat_8
      # 
      def rough_accounts_reject(array_numbers, *args)
        args.each do |a|
          array_numbers.reject! {|n| n =~ /^[-!]?#{a}\d*/}
        end
        array_numbers
      end

      # rencoie la liste brute des informations de comptes repris dans la partie doc
      # rough_accounts_list(:benevolat) renvoie par exemple %w(87 !870 870 86 !864 864)
      def rough_accounts_list(doc)
        if @instructions[doc]
          accumulated_values(@instructions[doc][:rubriks]).join(' ').split
        else
          []
        end
      end




      # doc est un symbol comme :actif, :passif, :resultat
      def numbers_from_document(doc)
        if @instructions[doc]
          accumulated_values(@instructions[doc][:rubriks]).map {|accounts| Compta::RubrikParser.new(@period, :actif, accounts).list_numbers}.flatten
        else
          []
        end
      end

      

      def numbers_with_options_from_document(doc)
           accumulated_values(@instructions[doc][:rubriks]).map {|accounts| Compta::RubrikParser.new(@period, :actif, accounts).list}.flatten
      end

      def collection_numbers_with_option(*docs)
        r = []
        docs.each {|doc| r+= numbers_with_options_from_document(doc)}
        r
      end

      # à partir d'une liste de numéros, retourne la liste des doublons
      def doublon_in_list(array_numbers)
        uniq_numbers = array_numbers.uniq
        if uniq_numbers.size != array_numbers.size
          # pour trouver les dupliqués, on fait un hash avec comme clé le numéro et comme nombre le count de fois ce numéro
          return array_numbers.inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
        end
        []
      end

       # permet d'extraire toutes les instructions de liste de comptes de la nomenclature
      # la logique récursive permet de faire des nomenclatures à plusieurs niveaux
      # sans imposer un nombre de niveaux précis
      def accumulated_values(hash_rubriks)
        values = []
        hash_rubriks.each do |k,v|
          values << (v.is_a?(Hash) ? accumulated_values(v) : v)
        end
        values.flatten
      end

    
    end

  end
