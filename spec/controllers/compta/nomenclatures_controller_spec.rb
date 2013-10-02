# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Compta::NomenclaturesController do
  include SpecControllerHelper

  def valid_attributes
      
  end

  before(:each) do   
    minimal_instances
    @p.stub(:all_natures_linked_to_account?).and_return true 
    
  end
  
  describe 'GET show' do  
 
    it 'crée une sheet et l assigne' do
      @o.should_receive(:nomenclature).and_return(mock_model(Nomenclature))
      get :show, {}, valid_session
      assigns(:nomenclature).should be_a(Nomenclature)  
    end




  end

    
  

end

