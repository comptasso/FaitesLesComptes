# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BankExtractLinesController do
  include SpecControllerHelper 


  
  let(:be) {mock_model(BankExtract,
      bank_account: stub_model(BankAccount),
      begin_date: Date.today.beginning_of_month,
      end_date: Date.today.end_of_month,
      begin_sold: 120, debit: 450, credit: 1000, end_sold: 120+1000-450)}
 
  
   def valid_params
      {"bank_extract_id"=>be.to_param,  date:Date.today, position:1} 
   end


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

   describe 'POST regroup - degroup' do

     before(:each) do
       @bel1 = mock_model(BankExtractLine, valid_params)
       @bel2 = mock_model(BankExtractLine, valid_params)
       @bel1.stub(:lower_item).and_return @bel2
       BankExtractLine.stub(:find).with(@bel1.to_param).and_return @bel1
      
     end

     it 'regroupe avec la ligne suivante' do
      @bel1.should_receive(:regroup).with(@bel2).and_return(@bel1)
       post :regroup, {:bank_extract_id=>be.to_param, id:@bel1.to_param, :format=>:js}, valid_session
       response.should render_template 'regroup'
     end

     it 'degroupe scinde les écritures (et utilise le même js que regroup)' do
       @bel1.should_receive(:degroup).with().and_return(@bel1)
       post :degroup, {:bank_extract_id=>be.to_param, id:@bel1.to_param, :format=>:js}, valid_session
       response.should render_template 'regroup'
     end

     it 'remove appelle le template remove' do
       @bel1.should_receive(:destroy)
       Utilities::NotPointedLines.should_receive(:new).and_return ['npl1', 'npl2']
       post :remove, {:bank_extract_id=>be.to_param, id:@bel1.to_param, :format=>:js}, valid_session
       response.should render_template 'remove'
       assigns[:lines_to_point].should == ['npl1', 'npl2']
     end

     it 'un ajout réussi appelle le template ajoute' do
       ComptaLine.should_receive(:find).with({"id"=>1}).and_return(@cl = double(ComptaLine))
       @a.should_receive(:new).with(:compta_lines=>[@cl]).and_return @bel1
       @bel1.should_receive(:save).and_return true
       Utilities::NotPointedLines.should_receive(:new).and_return ['npl1', 'npl2']
       post :ajoute, {:bank_extract_id=>be.to_param, :line_id=>{"id"=>1}, :format=>:js}, valid_session
       response.should render_template 'ajoute'
       assigns[:lines_to_point].should == ['npl1', 'npl2']
     end

     it 'un ajout qui échoue appelle le template flash_error' do
       ComptaLine.stub(:find).and_return(@cl = double(ComptaLine))
       @a.stub(:new).and_return @bel1
       @bel1.stub(:save).and_return false
       Utilities::NotPointedLines.should_not_receive(:new)
       post :ajoute, {:bank_extract_id=>be.to_param, :line_id=>{"id"=>1}, :format=>:js}, valid_session
       response.should render_template 'flash_error'
        
     end

     it 'insert ajoute une ligne déplacée par le drag and drop et lui donne sa position' do
       ComptaLine.should_receive(:find).with('545').and_return(@cl = double(ComptaLine))
       @a.stub(:new).and_return @bel1
       @bel1.should_receive(:position=).with(3)
       @bel1.stub(:save).and_return true
       post :insert, {:bank_extract_id=>be.to_param, :id=>@bel1.to_param, :html_id=>'line_545', :at=>'3', :format=>:js}, valid_session
       response.should render_template 'insert'
     end

     it 'insert avec erreur renvoie un flash_error' do
       ComptaLine.stub(:find).with('545').and_return(@cl = double(ComptaLine))
       @a.stub(:new).and_return @bel1
       @bel1.should_receive(:position=).with(3)
       @bel1.stub(:save).and_return false
       post :insert, {:bank_extract_id=>be.to_param, :id=>@bel1.to_param, :html_id=>'line_545', :at=>'3', :format=>:js}, valid_session
       response.should render_template 'flash_error'
     end

     it 'reorder prend 3 paramètres et déplace la ligne' do
       @bel1.should_receive(:move_higher).exactly(3).times
       post :reorder, {:bank_extract_id=>be.to_param, :id=>@bel1.to_param, :fromPosition=>'5', :toPosition=>'2', :format=>:js}, valid_session
       response.should render_template 'reorder'
     end

     it 'reorder vers le bas' do
       @bel1.should_receive(:move_lower).exactly(4).times
       post :reorder, {:bank_extract_id=>be.to_param, :id=>@bel1.to_param, :fromPosition=>'2', :toPosition=>'6', :format=>:js}, valid_session
       response.should render_template 'reorder'
     end

     it 'reorder avec une erreur renvoie une bad_request' do
       BankExtractLine.stub(:find).and_raise(ActiveRecord::RecordNotFound)
       @bel1.stub(:move_lower)
       post :reorder, {:bank_extract_id=>be.to_param, :id=>@bel1.to_param, :toPosition=>'6', :format=>:js}, valid_session
       response.code.should match /^4/
     end



   end


end

