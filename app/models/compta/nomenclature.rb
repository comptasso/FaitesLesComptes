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
  # TODO je pense que cette classe va disparaître après la refonte des nomenclatures
  # et des folios
  #
  class Nomenclature

    include ActiveModel::Validations

    attr_accessor :nomenclature

    
    delegate :resultat, :actif, :passif, :benevolat, :to=>:nomenclature
    
    validate :bilan_complete, :resultat_complete
    
  # TODO déplacer ces validations vers Nomenclature
  #     validate :bilan_balanced, :resultats_67, :benevolat_8, :no_doublon?
  # validates :actif, :passif, :resultat, :presence=>true



    # initialize se faire à partir d'un exercice et d'une nomenclature.
    #
    # En pratique, une nomenclature se crée avec la nomenclature
    # de l'organisme
    #
    def initialize(period, nomenclature)
      @period = period
      @nomenclature = nomenclature
    end

     # renvoie les noms des folios existant dans cette nomenclature
      def pages
        nomenclature.folios.map(&:name)
      end
      
        
    # renvoie une page, par exemple :actif ou :passif, ou :bilan sous forme d'une
    # instance de Compta::Sheet
    # doc doit être un des folios
      def sheet(doc)
        Compta::Sheet2.new(@period, doc) if doc
      end
      
#      def sheet2(doc)
#        Compta::Sheet2.new(@period, doc)
#      end

# TODO réactiver ce test sur la cohérence des comptes car pour le bilan, 
# il n'est pas possible de tester totalement la nomenclature et les folios associés
# si on ne teste pas également avec les comptes réels.
# 
# On pourrait par exemple tromper l'analyse avec un 43 !431 mais pas mettre le 431
# ou encore un -456 et ailleur un 45 
# 
# 
      

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
#      def collection_with_option_no_doublon?(name, *docs)
#        numbers = collection_numbers_with_option(*docs)
#        dup = []
#        # on doit vérifier que les nil et les col2 n'ont aucun doublon
#        list = numbers.select {|o| o[:option] == nil || o[:option] == :col2}.map {|n| n[:num]}
#        dup += doublon_in_list(list)
#      
#        # on n'accepte pas non plus des doublons entre les nil col2 et les credit d'un côté, les débit de l'autre
#        # les comptes de crédit ne peuvent être dans list
#        n_credit = numbers.select {|n| n[:option] == :credit}.map {|n| n[:num]}
#        dup +=  (n_credit & list) # intersection avec list
#        dup += doublon_in_list(n_credit)
#        # les comptes de débit ne peuvent être dans list
#        n_debit = numbers.select {|n| n[:option] == :credit}.map {|n| n[:num]}
#        dup += (n_debit & list) # intersection avec list
#        dup += doublon_in_list(n_debit)
#        self.errors[name] << "comprend des doublons (#{dup.uniq.join(', ')})" unless dup.empty?
#      end

      

      # Indique si le document bilan utilise tous les comptes de bilan
      def bilan_complete?
        bilan_complete.empty? ? true : false 
      end
   
      
      # vérifie que tous les comptes sont pris en compte pour l'établissement du bilan
      # à l'exception des comptes de classes 8 qui servent à valoriser le bénévolat
      def bilan_complete
        list_accs = @period.two_period_account_numbers # on a la liste des comptes
        rubrik_accs = []
        rubrik_accs += numbers_from_document(actif) + numbers_from_document(passif)
        not_selected =  list_accs.select {|a| !a.in?(rubrik_accs) && !(a=~/^8\d*$/) }
        unless not_selected.empty?
          self.errors[:bilan] << "ne reprend pas tous les comptes. Manque #{not_selected.join(', ')}"
        end
        return not_selected
      end
      
      
protected

      # vérifie que tous les comptes 6 et 7 sont pris en compte pour l'établissement du compte de résultats 
      def resultat_complete
        list_accs = @period.two_period_account_numbers.reject {|acc| acc.to_s =~ /\A[123458]\d*/}
        rubrik_accounts = numbers_from_document(resultat)
        not_selected =  list_accs.select {|a| !a.in?(rubrik_accounts) }
        self.errors[:resultat] << "Le compte de résultats ne reprend pas tous les comptes 6 et 7. Manque #{not_selected.join(', ')}" if not_selected.any?
      end

   

      
      

    

      
      
      # doc est un symbol comme :actif, :passif, :resultat
      def numbers_from_document(doc)
        if doc
          doc.all_numbers.map {|accounts| Compta::RubrikParser.new(@period, :actif, accounts).list_numbers}.flatten
        else
          [] 
        end
      end

      

      def numbers_with_options_from_document(doc)
           doc.all_numbers.map {|accounts| Compta::RubrikParser.new(@period, :actif, accounts).list}.flatten
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

     

    
    end

  end
