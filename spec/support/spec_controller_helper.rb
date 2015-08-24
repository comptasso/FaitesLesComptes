# coding: utf-8

# module destiné à être inclus dans les spec des controllers pour avoir les
# instances de base
#
module SpecControllerHelper

#   def sign_in(user = double('user'))
#     if user.nil?
#       request.env['warden'].stub(:authenticate!).
#         and_throw(:warden, {:scope => :user})
#       controller.stub :current_user => nil
#     else
#       puts "Dans sign_in Warden : #{request.env['warden']}"
#       request.env['warden'].stub :authenticate! => user
#       controller.stub :current_user => user
#     end
#   end

  # définit les instances et les stub nécessaires pour passer les before filter (log_in?
  # find_organism, current_period, current_user
  def minimal_instances
    # Tenant.set_current_tenant(tenants(:tenant_1).id)
    @t = tenants(:tenant_1)
    @cu = users(:quentin)

#    @cu = mock_model(User, tenant_id:@t.id) # cu pour current_user
    Tenant.set_current_tenant(@t)
    sign_in(@cu) # introduit suite à Devise
    controller.stub :current_user=>@cu
    @o = mock_model(Organism,
      title:'le titre',
      sectored?:false,
      tenant_id:@t.id)
    @p = mock_model(Period, :start_date=>Date.today.beginning_of_year,
      close_date:Date.today.end_of_year, open?:true,
      organism:@o,
      guess_date:Date.today,
      guess_month:MonthYear.from_date(Date.today),
      guess_month_from_params:MonthYear.from_date(Date.today),
      next_piece_number:777, tenant_id:@t.id)

    @cu.stub(:tenants).and_return [@t]
    @cu.stub(:organisms).and_return(@or = double(Arel))
    @or.stub(:find).and_return @o
    @or.stub(:first).and_return @o
    @sect = mock_model(Sector, tenant_id:@t.id)

    Tenant.stub(:find_by_id).with(@t.id).and_return @t
    Organism.stub(:first).and_return(@o)
    User.stub(:find_by_id).with(@cu.id).and_return @cu
    Period.stub(:find_by_id).with(@p.id).and_return @p

    @o.stub(:guess_period).and_return(@p)
    @o.stub_chain(:periods, :find_by_id).and_return @p
    @o.stub_chain(:periods, :order, :last).and_return(@p)
    @o.stub_chain(:periods, :empty?).and_return false
    @o.stub_chain(:periods, :any?).and_return !(@o.periods.empty?)
    @o.stub_chain(:periods, :last).and_return(@p)
    @o.stub_chain(:books, :in_outs, :all).and_return [1,2]
    @o.stub_chain(:sectors, :first).and_return @sect

  end


  # définit les attributs de session systématiques
  def session_attributes
    {period:@p.id, org_db:@o.id}
  end

  # cet alias permet d'utiliser les spec créés par scaffold sans avoir à rebaptiser
  # session_attributes
  alias  valid_session session_attributes
end
