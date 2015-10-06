# coding: utf-8

require 'spec_helper'
require 'support/spec_controller_helper'

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
          tempfile: "#{Rails.root}/spec/assets/importer/releve.csv}",
          filename:"releve.csv"})
      end

     def lefichierofx
       @uploaded_ofx ||=  ActionDispatch::Http::UploadedFile.new({
          tempfile: "#{Rails.root}/spec/assets/importer/releve.ofx",
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

     it 'ou redirige vers index de imported_bels' do
       Importer::Loader.stub(:new).
        and_return(double(Importer::Loader, save:true))
      post :create, {bank_account_id:ba.to_param, importer_loader:{file:lefichiercsv} }, valid_session
      response.should redirect_to bank_account_imported_bels_url(ba)
     end



  end


end
