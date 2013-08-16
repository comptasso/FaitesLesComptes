# coding: utf-8

# Cet observateur permet l'intégration avec le gem Adherent et plus précisément
# son modèle de payment. 
# 
# Enregistrer un payment entraîne la création d'une écriture comptable
# 
# TODO : voir comment traiter les natures et destinations qui servent pour
# l'enregistrement des payements des membres.
#
module Adherent
  class PaymentObserver < ::ActiveRecord::Observer
    
    attr_reader :organism, :member, :period
    
    def after_create(record)
      # trouver le livre de recette (par défaut on prend le premier)
      @member = record.member
      @organism = member.organism
      set_period(record)
      
      ib = organism.income_books.first
      w = ib.in_out_writings.new(
         date:record.read_attribute(:date),
         ref:"adh #{member.number} #{record.id}",
         narration:"Payment adhérent #{member.to_s}",
         compta_lines_attributes:{'1'=>compta_line_attributes(record),
           '2'=>counter_line_attributes(record)}
      )
      
      puts w.errors.messages unless w.valid?
      w.save!
    end
    
    def after_update
      
    end
    
    protected
    
    def set_period(record)
      @period = organism.find_period(record.read_attribute(:date))
    end
      
    def compta_line_attributes(record)
      destination = organism.destinations.find_by_name('Adhérents')
      nature =  period.natures.find_by_name('Cotisations des adhérents')
      {nature_id:nature.id, destination_id:destination.id, credit:record.amount, debit:0}
    end
    
    def counter_line_attributes(record) 
      # selon le mode de paiment, il faut trouver le compte comptable à mouvementer
      # si c'est en Espèces, c'est la caisse, si c'est autrement, c'est la banque
      if record.mode == 'Espèces'
        account = period.list_cash_accounts.first
      else
        account = period.list_bank_accounts.first
      end
      {account_id:account.id, payment_mode:record.mode, debit:record.amount, credit:0}
    end
  end
end
