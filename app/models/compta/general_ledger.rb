# coding: utf-8

# Classe intermédiaire rajoutée par cohérence avec les autres classes telles que 
# Balance. 
# 
# Cette classe ne sert qu'à générer le journal général qui ne se fait qu'en pdf
# TODO : on pourrait très bien l'avoir à l'écran
#
# Sa méthode to_pdf est nécessaire pour que le GeneralLedgerPdfFiller fonctionne
# correctement.
class Compta::GeneralLedger
  
  def initialize(period)
    @period = period
  end
  
  def to_pdf
    Compta::PdfGeneralLedger.new(@period)
  end
  
end
