module ImportedBelsHelper
  
  # fournit la collection de mode de payment nécessaire pour l'édition en ligne
  # des imported_bels.
  # TODO faire une collection différente pour les transferts
  def collection_payment_mode(ibel)
    if ibel.cat != 'T'
      coll_payment_mode 
    else
      transfer_counterpart
    end
  end
  
  
  # Fait une collection des caisses et banques. La construction de l'id est 
  # particulière pour tenir compte que dans la  même liste on a des caisses et 
  # des banques.
  # Ceci impose au controller de trouver la contrepartie de façon plus fine 
  # qu'un simple find.
  def transfer_counterpart
    bas = @organism.bank_accounts.collect{|ba| ["bank_#{ba.id}", ba.nickname]}.
        reject {|r| r.first == "bank_#{@bank_account.id}" }
      cas = @organism.cashes.collect {|ca| ["cash_#{ca.id}", ca.name]}
      bas + cas 
  end
  
  def coll_payment_mode
    PAYMENT_MODES.reject{|pm| pm == 'Espèces'}.map {|pm| [pm, pm]}
  end
  
  
  
  
  
  
  # la collection peut être T pour un transfert, D pour une dépense, R pour 
  #  une recette, C pour une remise de chèque
  #  
  #  Pour les écritures qui sont des débits, on peut avoir D ou T
  #  Pour les crédits on peut avoir R T C
  #
  def collection_cat(ibel)
    if ibel.debit != 0.0
      [['D', 'D'], ['T', 'T']]
    else
      [['R', 'R'], ['T', 'T'], ['C', 'C']]
    end
  end
  
  # renvoie les natures correspondant à l'exercice en cours en fonction de l'ibel
  def collection_nature(ibel)
    ar =  ibel.depense? ? @period.natures.depenses : @period.natures.recettes
    ar.all.collect {|n| [n.id, n.name]}
  end
end
