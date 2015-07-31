# coding: utf-8

require 'spec_helper'
require 'support/spec_controller_helper'

RSpec.configure do |c|
  #   c.filter = {:wip=>true}
end

# on utilise Admin::PeriodsController mais le but de cette spec est de faire les tests
# des actions before_filter de application_controller.
#
# L'objet de ces spec est donc plutôt de vérifier le bon fonctionnement
# des informations de sessions
describe Admin::PeriodsController do
  include SpecControllerHelper
  let(:p) {mock_model(Period)}
  let(:o) {mock_model(Organism, guess_period:p)}

  before(:each) do
    Tenant.set_current_tenant(tenants(:tenant_1))
    @cu = users(:quentin)
    o.stub(:periods).and_return(@br = double(Arel))
    @br.stub(:order).and_return [p]
    @br.stub(:find_by_id).and_return p
    @br.stub('empty?').and_return false
    @br.stub(:last).and_return p

  end

  describe 'before_filters' do

    context 'signed' do

      before(:each) do
        sign_in(@cu)
        @cu.stub(:organisms).and_return [o]
      end

      describe 'find_organism'  do
        it 'pas d organisme si pas de session de org_db ni d organismes pour le user', wip:true do
          User.any_instance.stub(:organisms).and_return []
          get :index
          assigns(:organism).should == nil
        end

        it 'si session[:org_db, cherche la chambre et assigne @organism' do
          Organism.should_receive(:find_by_id).with('bonjour').and_return(o)
          get :index, {}, {org_id:'bonjour'}
          assigns(:organism).should == o
        end

      end

      describe 'current_period', wip:true do

        before(:each) do
          sign_in(@cu)
          Organism.stub(:find_by_id).and_return o
        end

        context 'sans organisme' do

          it 'rien sans organisme' do
            User.any_instance.stub(:organisms).and_return []
            get :index, {}
            assigns(:organism).should be_nil
            assigns(:period).should be_nil
          end

        end

        context 'avec un organisme' do

          before(:each) do
            @cu.stub(:organisms).and_return [o]
          end

          it 'assigne l organisme' do
            get :index, {}, {user:@cu.id, org_id:o.id}
            assigns(:organism).should == o
          end

          it 'look for period when there is no session period', wip:true do
            o.should_receive(:guess_period).exactly(1).times.and_return(p)
            get :index, {}, {user:@cu.id, org_id:o.id}
          end

          it 'la session de period est renseignée si elle n était pas renseignée' do
            session[:period] = nil
            get :index,{}, {user:@cu.id, org_id:o.id}
            session[:period].should == p.id
          end

          it 'cas où on fournit les sessions de org et de period' do
            get :index,{}, {user:@cu.id, org_id:o.id, period:p.id}
            assigns(:period).should == p
            session[:period].should == p.id
          end

        end
      end

      describe 'sign_out' do

        it 'renvoie vers la page bye quand on se déloggue' do
          pending 'à faire'

        end
      end

      describe 'export_filename' do

        let(:obj) {double(Object, title:'Bilan')}
        let(:dat) { I18n.l(Date.today, format:'%d-%b-%Y').gsub('.', '') }

        before(:each) do
          @ac = ApplicationController.new
          o.stub(:title).and_return 'Asso Test'
          @ac.instance_variable_set('@organism', o)

        end

        it 'renvoie le titre, le nom de l organisme et la date plus l extension'  do
          @ac.export_filename(obj, :pdf).should == "Bilan Asso Test #{dat}.pdf"
        end

        it 'ou avec le dernier item de la classe de l objet si pas de titre' do
          obje = double(Object)
          @ac.export_filename(obje, :pdf).should == "Mock Asso Test #{dat}.pdf"
        end

        it 'on peut imposer le titre' do
          @ac.export_filename(obj, :pdf, 'TITRE').should == "TITRE Asso Test #{dat}.pdf"
        end


      end




    end
  end

end
