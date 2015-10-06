module Jobs

  # class permettant de remplir en arrière plan toutes les données d'un nouvel
  # exercice
  class NomenclatureFillRubriks < Struct.new(:tenant_id, :period_id)

    def before(job)
#      Apartment::Database.process(db_name) do
      Tenant.set_current_tenant(tenant_id)
        @period = Period.find(period_id)
        @nomenclature = @period.organism.nomenclature
 #     end
    end

    def perform
  #    Apartment::Database.process(db_name) do
      Tenant.set_current_tenant(tenant_id)
        @nomenclature.rubriks.each do |r|
          r.fill_values(@period)
   #     end

      end
    end

    def success(job)
#      Apartment::Database.process(db_name) do
      Tenant.set_current_tenant(tenant_id)
        @nomenclature.update_attribute(:job_finished_at, Time.current)
#      end
    end

  end

end
