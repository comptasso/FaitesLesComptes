require 'spec_helper'
require 'support/spec_controller_helper'

RSpec.configure do |c|
  #  c.filter = {:wip=>true}
end



describe ImportedBelsController do
  include SpecControllerHelper

  let(:ba) {stub_model(BankAccount, name: 'IBAN', number: '124578A', organism_id: @o.id)}

  before(:each) do
    minimal_instances
    BankAccount.stub(:find).and_return(ba)


  end

  describe 'GET index' do

    before(:each) do
      ba.stub_chain(:bank_extracts, :period, :order).
        and_return([mock_model(BankExtract, begin_date:Date.today.beginning_of_month,
            end_date:Date.today.end_of_month)])
    end

    it 'recherche la banque' do
      BankAccount.should_receive(:find).with(ba.to_param).and_return ba
      get :index,{bank_account_id: ba.to_param}, valid_session
    end
  end

  describe  'DELETE destroy' do

    it 'trouve l ibel et le détruit' do
      BankAccount.should_receive(:find).with(ba.to_param).and_return ba
      ImportedBel.should_receive(:find_by_id).with('3').and_return(@ibel = mock_model(ImportedBel))
      @ibel.should_receive(:destroy)
      delete :destroy, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
    end


  end

  describe 'POST write' do

    def writing_params
      {ref:'ref', compta_lines_attributes:{'0'=>
            {nature_id:1, destination_id:1, debit:10, credit:0},
          '1'=>{account_id:2, debit:0, credit:10}}}
    end

    before(:each) do
      @ibel = mock_model(ImportedBel, depense?:true, update_attribute:true)
      ImportedBel.stub(:find).with('3').and_return(@ibel)
      @ibel.stub(:to_write).and_return(writing_params)

      ba.stub_chain(:sector, :outcome_book).and_return(@ob = mock_model(OutcomeBook))
      @ob.stub(:in_out_writings).and_return(@ar = double(Arel))
      @ar.stub(:new).and_return(@w = mock_model(Writing,
          save:true, support_line:mock_model(ComptaLine)))
      @controller.stub(:fill_author)
      ba.stub_chain(:bank_extracts, :where, :first).and_return(@bex = mock_model(BankExtract))
      @bex.stub_chain(:bank_extract_lines, :create).and_return true
    end

    it 'cheche le ImportedBel' do
      ImportedBel.should_receive(:find).with('3').and_return @ibel
      post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
    end

    it 'écrit l\'écriture' do
      @ibel.should_receive(:to_write).and_return writing_params
      post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
    end

    context 'en cas de succès' do

      it 'affecte l\'écriture' do

        post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
        assigns(:writing).should == @w
      end

      it 'memorise dans l ibel le numero de la compta_line' do
        @ibel.should_receive(:update_attribute).with(:writing_id, @w.id)
        post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session

      end

      it 'cherche le bank_extract' do
        ba.should_receive(:bank_extracts).and_return(@ar = double(Arel))
        @ar.should_receive(:where).with('begin_date <= ? AND end_date >= ?',
          @ibel.date, @ibel.date).and_return([@bex])
        post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
      end

      it 'pour y écrire une bank_extract_line' do
        @bex.should_receive(:bank_extract_lines).and_return(@ar = double(Arel))
        @ar.should_receive(:create).with(compta_line_id:@w.support_line.id)
        post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
      end



    end

    context 'en cas d échec' do

      before(:each) do
        @w.stub(:save).and_return false
      end

      it 'renvoie un message d erreur' do
        @w.errors.add(:base, 'une explication')
        post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
        assigns(:message).should ==
          "Erreur lors de la création de l'écriture : une explication"
      end

    end
  end

  describe 'DELETE destroy_all' , wip:true do

    it 'renvoie un message d erreur' do
      ba.should_receive(:imported_bels).and_return(ar = double(Arel))
      ar.should_receive(:delete_all)
      delete :destroy_all, {bank_account_id:ba.to_param}, valid_session
    end

  end




end
