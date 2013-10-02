# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Compta::SheetsController do
  include SpecControllerHelper

  def valid_attributes
      
  end

  before(:each) do 
    minimal_instances
    @p.stub(:all_natures_linked_to_account?).and_return true 
    @o.stub(:nomenclature).and_return(mock_model(Nomenclature, valid?:true))
    @f = mock_model(Folio)    
  end
  
  it 'le controller s assure que la nomenclature est valide'
  
  

    describe 'GET show' do  

      it 'crée une sheet et l assigne' do
        get :show, {:id=>@f.to_param}, valid_session
        assigns(:sheet).should be_a(Compta::Sheet)
      end

#      it 'sans params[:compta_balance] redirige vers new' do
#        get :show, {:period_id=>@p.id.to_s}, valid_session
#        response.should redirect_to new_compta_period_balance_url(@p) 
#      end
#
#      it 'rend le csv' do
#        Compta::Balance.any_instance.stub(:valid?).and_return(true)
#        Compta::Balance.any_instance.stub(:to_csv).and_return('ceci est une chaine csv\tune autre\tencoe\tenfin\n')
#        @controller.should_receive(:send_data).with('ceci est une chaine csv\tune autre\tencoe\tenfin\n').and_return { @controller.render nothing: true }
#        get :show, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes, :format=>'csv'}, valid_session
#      end
#
#       it 'rend le xls' do
#        Compta::Balance.any_instance.stub(:valid?).and_return true
#        Compta::Balance.any_instance.stub(:to_xls).and_return 'Bonjour'
#        @controller.should_receive(:send_data).with('Bonjour').and_return { @controller.render nothing: true }
#        get :show, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes, :format=>'xls'}, valid_session
#      end


    end

    
  

end

