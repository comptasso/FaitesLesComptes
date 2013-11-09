# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe BankExtractLinesController do 
  include SpecControllerHelper 


  
  let(:be) {mock_model(BankExtract,
      bank_account: stub_model(BankAccount),
      begin_date: Date.today.beginning_of_month,
      end_date: Date.today.end_of_month,
      begin_sold: 120, debit: 450, credit: 1000, end_sold: 120+1000-450)}
 
  
   


  before(:each) do
    minimal_instances
    BankExtract.stub(:find).with(be.to_param).and_return be
    be.stub(:bank_extract_lines).and_return(@a = double(Arel))
    @a.stub(:order).with(:position).and_return ['bel1', 'bel2']
  end

  describe "GET index" do
    it "récupère les bel ordonnées par position" do
      
      get :index,{:bank_extract_id=>be.to_param}, valid_session
      assigns[:period].should == @p
      assigns[:bank_extract_lines].should == ['bel1', 'bel2']
    end
  end
  
  describe "GET pointage", wip:true do
    
    before(:each) do
      @controller.stub(:prepare_modal_box_instances).and_return nil
    end
    
    it 'rend la vue pointage' do
      get :pointage, {:bank_extract_id=>be.to_param}, valid_session
      response.should render_template 'pointage'
    end
    
    it 'redirige vers lines_to_pointsi le bank_extract est locked' do
      be.stub(:locked).and_return true
      get :pointage, {:bank_extract_id=>be.to_param}, valid_session
      response.should redirect_to lines_to_point_bank_extract_bank_extract_lines_url(be)
    end
    
    
  end
  
  
  
   
   
  describe 'POST enregistrer' do
    
    def valid_params
      {"bank_extract_id"=>be.to_param,  lines:{'0'=>'25', '1'=>'53', '2'=>'89'}, :format=>:js} 
    end
     
    it 'récupère d abord toutes les bank_extract_lines du bank_extract et les efface' do
      be.should_receive(:bank_extract_lines).
        and_return([@bel1 = double(BankExtractLine), @bel2 = double(BankExtractLine)])
      @bel1.should_receive(:destroy)
      @bel2.should_receive(:destroy)
      post :enregistrer, {"bank_extract_id"=>be.to_param, :format=>:js}, valid_session
    end
     
    context 'les comptalines sont bien sauvées' do
      
      before(:each) do
        be.stub(:bank_extract_lines).and_return(@ar = double(Arel))
        @ar.stub(:each).and_return nil # on a déjà testé la destruction des bank_extract_lines
        @ar.stub(:new).and_return(mock_model(BankExtractLine, 'position='=>true, :save=>true).as_new_record)
      end
           
      it 'assigne le bank_extract' do
        
        @p.stub_chain(:compta_lines, :find_by_id).and_return(double(ComptaLine, id:'1'))
        post :enregistrer, valid_params, valid_session
        assigns[:bank_extract].should == be
      end
      
      it 'cherche les 3 compta_lines indiquées par valid_session' do
        
        @p.stub(:compta_lines).and_return(@ar2 =double(Arel))
        @ar2.should_receive(:find_by_id).with('25').and_return(double(ComptaLine, id:'3'))
        @ar2.should_receive(:find_by_id).with('53').and_return(double(ComptaLine, id:'5'))
        @ar2.should_receive(:find_by_id).with('89').and_return(double(ComptaLine, id:'6'))
        post :enregistrer, valid_params, valid_session
        
      end
      
      it 'crée les bank_extract_lines' do
        @p.stub(:compta_lines).and_return(@ar2 =double(Arel))
        @ar2.stub(:find_by_id).with('25').and_return(@cl1 = double(ComptaLine, id:'7'))
        @ar2.stub(:find_by_id).with('53').and_return(@cl2 = double(ComptaLine, id:'8'))
        @ar2.stub(:find_by_id).with('89').and_return(@cl3 = double(ComptaLine, id:'9'))
        @ar.should_receive(:new).with(:compta_line_id=>@cl1.id).and_return(double(BankExtractLine, 'position='=>true, :save=>true))
        @ar.should_receive(:new).with(:compta_line_id=>@cl2.id).and_return(double(BankExtractLine, 'position='=>true, :save=>true))
        @ar.should_receive(:new).with(:compta_line_id=>@cl3.id).and_return(double(BankExtractLine, 'position='=>true, :save=>true))
        post :enregistrer, valid_params, valid_session
        
      end
      
      it 'affecte leurs positions' do
        @p.stub(:compta_lines).and_return(@ar2 =double(Arel))
        @ar2.stub(:find_by_id).and_return(double(ComptaLine, id:'10'))
        @ar.stub(:new).and_return(@new_bel = double(BankExtractLine, :save=>true))
        @new_bel.should_receive('position=').with('0')
        @new_bel.should_receive('position=').with('1')
        @new_bel.should_receive('position=').with('2')
        post :enregistrer, valid_params, valid_session     
      end 
      
      it 'et les sauve' do
        @p.stub(:compta_lines).and_return(@ar2 =double(Arel))
        @ar2.stub(:find_by_id).and_return(double(ComptaLine, id:'11'))
        @ar.stub(:new).and_return(@new_bel = double(BankExtractLine, 'position='=>true))
        @new_bel.should_receive(:save).exactly(3).times
        post :enregistrer, valid_params, valid_session     
      end
      
      it 'lorsque tout est correctement sauvé, @ok vaut true' do
        @p.stub(:compta_lines).and_return(@ar2 =double(Arel))
        @ar2.stub(:find_by_id).and_return(double(ComptaLine, id:'12'))
        @ar.stub(:new).and_return(double(BankExtractLine, 'position='=>true, :save=>true))
        post :enregistrer, valid_params, valid_session    
        assigns[:ok].should be_true
      end
      
      it 'si une bel n est pas sauvée, @ok vaut false' do
        @p.stub(:compta_lines).and_return(@ar2 =double(Arel))
        @ar2.stub(:find_by_id).and_return(double(ComptaLine, id:'13'))
        @ar.stub(:new).and_return(
          double(BankExtractLine, 'position='=>true, :save=>true),
          double(BankExtractLine, 'position='=>true, :save=>false),
          double(BankExtractLine, 'position='=>true, :save=>true)
        )
        post :enregistrer, valid_params, valid_session    
        assigns[:ok].should be_false
      end
      
      it 'l action rend le template enregistrer' do
        @p.stub(:compta_lines).and_return(@ar2 =double(Arel))
        @ar2.stub(:find_by_id).and_return(double(ComptaLine, id:'14'))
        @ar.stub(:new).and_return(double(BankExtractLine, 'position='=>true, :save=>true))
        post :enregistrer, valid_params, valid_session  
        response.should render_template 'enregistrer'
      end
      
    end
  end

end

