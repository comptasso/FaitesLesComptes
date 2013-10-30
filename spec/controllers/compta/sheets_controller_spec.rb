# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Compta::SheetsController do
  include SpecControllerHelper

  def valid_attributes
      
  end

  before(:each) do 
    minimal_instances
    @p.stub(:all_natures_linked_to_account?).and_return true 
    @o.stub(:nomenclature).and_return(@nomen = mock_model(Nomenclature, coherent?:true))
    @f = mock_model(Folio)    
  end
  
  it 'le controller s assure que la nomenclature est valide' do
    
    
  end
  
  # TODO finir les specs de ce controller

  describe 'GET show' do  
      
    before(:each) do
      @nomen.stub(:folios).and_return(@ar = double(Arel))
    end
    
    context 'quand nomenclature n est pas coherent' do
      
      before(:each) do
        @nomen.stub('coherent?').and_return false
        @ar.stub(:find).and_return @f
        @nomen.stub(:sheet).with(@p, @f).and_return(@cs = double(Compta::Sheet, valid?:true))
        @cs.stub(:to_html).and_return(@list_rubriks = double(Array))
      end
    
    
      it 'l action show déclanche check_nomenclature' do
        controller.should_receive('collect_errors').with(@nomen).and_return 'la liste des erreurs'
        get :show, {:id=>@f.to_param}, valid_session
      end
    
      it 'l action show déclanche check_nomenclature' do
        controller.stub('collect_errors').with(@nomen).and_return 'la liste des erreurs'
        get :show, {:id=>@f.to_param}, valid_session
        flash[:alert].should == 'la liste des erreurs'
      end
    
    
    
    end
    
    it 'cherche le folio à partir du param' do
      @ar.should_receive(:find).with(@f.to_param).and_return @f
      @nomen.should_receive(:sheet).with(@p, @f).and_return(@cs = double(Compta::Sheet, valid?:true))
      @cs.should_receive(:to_html).and_return(@list_rubriks = double(Array))
      get :show, {:id=>@f.to_param}, valid_session
    end

    it 'crée une sheet et l assigne' do
      @ar.stub(:find).and_return @f
      @nomen.stub(:sheet).with(@p, @f).and_return(@cs = double(Compta::Sheet, valid?:true))
      @cs.stub(:to_html).and_return(@list_rubriks = double(Array))
      get :show, {:id=>@f.to_param}, valid_session
      assigns(:rubriks).should == @list_rubriks
    end 
    
    it 'si le document n est pas valide, renvoie vers la liste des documents' do
      @ar.stub(:find).and_return @f
      @nomen.stub(:sheet).with(@p, @f).and_return(@cs = double(Compta::Sheet, valid?:false))
      @cs.stub(:to_html).and_return(@list_rubriks = double(Array))
      @cs.stub_chain(:errors, :full_messages, :join).and_return 'Le texte de l erreur'
      get :show, {:id=>@f.to_param}, valid_session
      response.should redirect_to compta_nomenclature_path
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

