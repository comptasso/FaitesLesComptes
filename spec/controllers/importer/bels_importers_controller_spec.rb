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
        and_return(double(Importer::BelsImporter, save:true))
      post :create, {bank_account_id:ba.to_param, importer_bels_importer:{bonus:1} }, valid_session 
    end
    
    it 'rend la vue new si echec de la sauvegarde' do
      Importer::BelsImporter.stub(:new).
        and_return(double(Importer::BelsImporter, save:false))
      post :create, {bank_account_id:ba.to_param, importer_bels_importer:{bonus:1} }, valid_session 
      response.should render_template 'new'
    end
    
    it 'vérifie que les extraits sont créés' do
      Importer::BelsImporter.stub(:new).
        and_return(@ibel = double(Importer::BelsImporter, save:true))
      @ibel.should_receive(:need_extract?).and_return(true)
      post :create, {bank_account_id:ba.to_param, importer_bels_importer:{bonus:1} }, valid_session 
      flash[:notice].should == 'Des écritures ont des dates qui ne sont pas couvertes par les extraits bancaires'
    end
    
    
  end
  
  
end