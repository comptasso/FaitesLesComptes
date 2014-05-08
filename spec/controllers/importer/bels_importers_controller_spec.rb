# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {wip:true} 
end



describe Importer::BelsImportersController do 
  include SpecControllerHelper
  
  let(:ba) {mock_model(BankAccount)}
  
  before(:each) do
    minimal_instances
    BankAccount.stub(:find).with(ba.to_param).and_return(ba)
  end
  
  
  describe 'POST create' do
    
    it 'créé le BelsImporter' do
      Importer::BelsImporter.should_receive(:new).
        with({"bonus"=>"1", "bank_account_id"=>ba.id}).
        and_return(double(Importer::BelsImporter, save:true, need_extract?:false))
      post :create, {bank_account_id:ba.to_param, importer_bels_importer:{bonus:1} }, valid_session 
    end
    
    it 'rend la vue new si echec de la sauvegarde' do
      Importer::BelsImporter.stub(:new).
        and_return(double(Importer::BelsImporter, save:false))
      post :create, {bank_account_id:ba.to_param, importer_bels_importer:{bonus:1} }, valid_session 
      response.should render_template 'new'
    end
    
    context 'il faut un extrait  de compte' do
      
      before(:each) do
        Importer::BelsImporter.stub(:new).
          and_return(@ibel = double(Importer::BelsImporter, save:true))
        @ibel.should_receive(:need_extract?).and_return(true)
      end
      it 'indique le besoin d un extrait' do 
        post :create, {bank_account_id:ba.to_param, importer_bels_importer:{bonus:1} }, valid_session 
        flash[:notice].should == 'Les écritures importées nécessitent la création d\'un extrait de compte'
      end
      
      it 'et renvoie sur new_bank_extract' do
        post :create, {bank_account_id:ba.to_param, importer_bels_importer:{bonus:1} }, valid_session 
        response.should redirect_to new_bank_account_bank_extract_url(ba)
      end
       
    end
    
    context 'sans besoin d un extrait  de compte' do
      
      before(:each) do
        Importer::BelsImporter.stub(:new).
          and_return(@ibel = double(Importer::BelsImporter, save:true))
        @ibel.should_receive(:need_extract?).and_return(false)
      end
      it 'indique le succès de  l importation' do 
        post :create, {bank_account_id:ba.to_param, importer_bels_importer:{bonus:1} }, valid_session 
        flash[:notice].should == 'Importation du relevé effectuée'
      end
      
      it 'et renvoie sur new_bank_extract' do
        post :create, {bank_account_id:ba.to_param, importer_bels_importer:{bonus:1} }, valid_session 
        response.should redirect_to bank_account_imported_bels_url(ba)
      end
       
    end
    
    
  end
  
  
end