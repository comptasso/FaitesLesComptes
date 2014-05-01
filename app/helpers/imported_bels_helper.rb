module ImportedBelsHelper
  
  # fournit la collection de mode de payment nécessaire pour l'édition en ligne
  # des imported_bels
  def collection_payment_mode
    PAYMENT_MODES.map {|pm| [pm, pm]}
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
