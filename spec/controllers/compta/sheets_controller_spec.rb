# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
 # c.filter = {wip:true}
end

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
  
  
  
  describe 'GET index' do
    
    before(:each) do
      @nomen.stub(:folios).and_return(@ar = double(Arel))
      @ar.stub(:find_by_name).and_return(@f)
      @nomen.stub(:sheet).and_return(@cs = double(Compta::Sheet))
    end
    
    it 'rend la vue index' do
      get :index, {:collection=>['bilan', 'resultat']}, valid_session
      response.should render_template('index')
    end
    
    it 'si la nomenclature est incoherent affiche une flash' do
      @nomen.stub('coherent?').and_return false
      controller.stub('collect_errors').and_return 'la liste des erreurs'
      get :index, {:collection=>['bilan', 'resultat']}, valid_session
      flash[:alert].should == 'la liste des erreurs'
    end
    
    describe 'exportations' do
      
      before(:each) do
        
      end
      
      it 'repond au format csv' do
        @cs.stub('to_index_csv').and_return 'des lignes aux format csv'
        controller.should_receive(:send_data).
          with('des lignes aux format csvdes lignes aux format csv', filename:'Bilan.csv').
          and_return { @controller.render nothing: true }
        get :index, {:collection=>['bilan', 'resultat'], title:'Bilan', :format=>'csv'}, valid_session
      end
      
      it 'repond au format xls' do
        @cs.stub('to_index_xls').and_return 'des lignes aux format xls\n'
        controller.should_receive(:send_data).
          with('des lignes aux format xls\ndes lignes aux format xls\n', filename:'Bilan.xls').
          and_return { @controller.render nothing: true }
        get :index, {:collection=>['bilan', 'resultat'], title:'Bilan', :format=>'xls'}, valid_session
      end
      
      it 'repond au format pdf' do
        controller.should_receive(:produce_pdf).with([@cs, @cs]).and_return('les données pdf')
        controller.should_receive(:send_data).
          with('les données pdf', filename:'Bilan.pdf').
          and_return { @controller.render nothing: true }
        get :index, {:collection=>['bilan', 'resultat'], title:'Bilan', :format=>'pdf'}, valid_session
      end
      
    end
    
  end

  describe 'GET show' do  
      
    before(:each) do
      @nomen.stub(:folios).and_return(@ar = double(Arel))
    end
    
    context 'quand nomenclature n est pas coherent' do
      
      before(:each) do
        @nomen.stub('coherent?').and_return false
        @ar.stub(:find).and_return @f
        @nomen.stub(:sheet).and_return(@cs = double(Compta::Sheet, valid?:true))
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

    describe 'GET bilans', wip:true do
      
      it 'redirige vers index' do
        get :bilans, {}, valid_session
        response.should redirect_to compta_sheets_path(collection:['actif', 'passif'], title:'Bilan')
      end
    end
    
    describe 'GET resultats', wip:true do
      
      it 'redirige vers index' do
        get :resultats, {}, valid_session
        response.should redirect_to compta_sheets_path(collection:['resultat'], title:'Compte de Résultats')
      end
    end

    describe 'GET bénévolats', wip:true do
      
      it 'redirige vers index' do
        get :benevolats, {}, valid_session
        response.should redirect_to compta_sheets_path(collection:['benevolat'], title:'Bénévolat')
      end
    end
    
    describe 'GET liasse', wip:true do
      
      it 'redirige vers index' do
        get :liasse, {}, valid_session
        response.should redirect_to compta_sheets_path(collection:['actif', 'passif', 'resultat', 'benevolat'], title:'Liasse complète')
      end
    end
  end

    
  

end

