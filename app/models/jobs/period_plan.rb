module Jobs

  # class permettant de remplir en arrière plan toutes les données d'un nouvel
  # exercice
  class PeriodPlan < Struct.new(:tenant_id, :period_id)

    def before(job)
      Tenant.set_current_tenant(tenant_id)
        @period = Period.find(period_id)
    end

    def perform
      Tenant.set_current_tenant(tenant_id)


        pc = plan_comptable

        if @period.previous_period?
          pc.copy_accounts(@period.previous_period)
          pc.copy_natures(@period.previous_period)
        else
          pc.create_accounts
          pc.create_bank_and_cash_accounts
          pc.create_rem_check_accounts
          pc.load_natures
        end
        @period.check_nomenclature
        # TODO probablement inutile si pas asssociation
        pc.fill_bridge
    end

    def success(job)
      Tenant.set_current_tenant(tenant_id)
#      end
#      Apartment::Database.process(db_name) do
        @period = Period.find(period_id)
        @period.update_attribute(:prepared, true)
#      end
    end

    protected


    def plan_comptable
      # TODO vraiment pas terrible de voir que Period doit solliciter organism.send(:status_class)
      statut = @period.organism.send(:status_class)
      if statut == 'Comite'
        Utilities::PlanComptableComite.new(@period)
      else
        Utilities::PlanComptable.new(@period, statut)
      end
    end

  end

end
