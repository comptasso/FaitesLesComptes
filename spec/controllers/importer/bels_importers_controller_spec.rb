# coding: utf-8

require 'spec_helper'


RSpec.configure do |c|
 #  c.filter = {wip:true}  
end



describe Importer::BelsImportersController do 
  include SpecControllerHelper
  
  let(:ba) {mock_model(BankAccount)} 
  
  before(:each) do
    minimal_instances
    BankAccount.stub(:find).with(ba.to_param).and_return(ba)
    BankAccount.stub(:find).with(ba.id).and_return(ba)
  end
  
  describe 'NEW' do
    
    it 'crée un Importer Loader' do
      Importer::Loader.should_receive(:new).and_return
      get :new, {bank_account_id:ba.to_param}, valid_session 
    end
    
    it 'assigne le ImporterLoader' do
      get :new, {bank_account_id:ba.to_param}, valid_session 
      assigns(:bels_importer).should be_an_instance_of(Importer::Loader)
    end
    
    
  end
  
  
  describe 'POST create' do
    
     def lefichiercsv 
       @uploaded_csv ||=  ActionDispatch::Http::UploadedFile.new({
          tempfile: "#{Rails.root}/spec/fixtures/importer/releve.csv}",
          filename:"releve.csv"})
      end
      
     def lefichierofx
       @uploaded_ofx ||=  ActionDispatch::Http::UploadedFile.new({
          tempfile: "#{Rails.root}/spec/fixtures/importer/releve.ofx",
          filename:"releve.ofx"})
     end
      
    
    it 'créé le BaseImporter' do
      Importer::Loader.should_receive(:new).
        with({"file"=>lefichiercsv, "bank_account_id"=>ba.id}).
        and_return(double(Importer::Loader, save:true, need_extract?:false))
      post :create, {bank_account_id:ba.to_param, importer_loader:{file:lefichiercsv} }, valid_session 
    end
    
    it 'rend la vue new si echec de la sauvegarde' do
      Importer::Loader.stub(:new).
        and_return(double(Importer::Loader, save:false))
      post :create, {bank_account_id:ba.to_param, importer_loader:{file:lefichiercsv} }, valid_session 
      response.should render_template 'new'
    end
    
    
    
    context 'il faut un extrait  de compte' do
      
      before(:each) do
        Importer::Loader.stub(:new).
          and_return(@ibel = double(Importer::Loader, save:true))
        @ibel.should_receive(:need_extract?).and_return(true)
      end
      it 'indique le besoin d un extrait' do 
        post :create, {bank_account_id:ba.to_param, importer_loader:{file:lefichiercsv} }, valid_session 
        flash[:notice].should == 'Les écritures importées nécessitent la création d\'un extrait de compte'
      end
      
      it 'et renvoie sur new_bank_extract' do
        post :create, {bank_account_id:ba.to_param, importer_loader:{file:lefichiercsv} }, valid_session 
        response.should redirect_to new_bank_account_bank_extract_url(ba)
      end
       
    end
    
    context 'sans besoin d un extrait  de compte' do
      
      before(:each) do
        Importer::Loader.stub(:new).
          and_return(@ibel = double(Importer::Loader, save:true))
        @ibel.should_receive(:need_extract?).and_return(false)
      end
      it 'indique le succès de  l importation' do 
        post :create, {bank_account_id:ba.to_param, importer_loader:{file:lefichiercsv} }, valid_session 
        flash[:notice].should == 'Importation du relevé effectuée'
      end
      
      it 'et renvoie sur new_bank_extract' do
        post :create, {bank_account_id:ba.to_param, importer_loader:{file:lefichiercsv} }, valid_session 
        response.should redirect_to bank_account_imported_bels_url(ba)
      end
       
    end
    
    
    
    
  end
  
  
end