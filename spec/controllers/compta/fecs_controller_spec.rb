# coding: utf-8 

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Compta::FecsController do  
  include SpecControllerHelper
  
  before(:each) do    
    minimal_instances
    @p.stub(:all_natures_linked_to_account?).and_return true
    @p.stub(:short_exercice).and_return '2013'
    
    
  end
  
  it 'rend un fichier csv' do
    Extract::Fec.any_instance.stub(:to_csv).and_return 'Bonsoir' 
    Extract::Fec.any_instance.stub(:fec_title).and_return '123456789FEC2015.csv'
    @controller.should_receive(:send_data).with('Bonsoir', filename:'123456789FEC2015.csv').
      and_return { @controller.render nothing: true }
    get :show, {:format=>'csv'}, valid_session
  end
  
  it 'construit un extract' do
    Extract::Fec.should_receive(:new).with(@p).and_return(@exf = double(Extract::Fec))
    @exf.stub(:to_csv).and_return(['test'])
    @exf.stub(:fec_title).and_return 'FEC2015.csv'
    get :show, {:format=>'csv'}, valid_session
  end
  
  it 'et l assigne comme @exfec' do
    Extract::Fec.stub(:new).and_return(@exf = double(Extract::Fec))
    @exf.stub(:to_csv).and_return(['test'])
    @exf.stub(:fec_title).and_return 'FEC2015.csv'
    get :show, {:format=>'csv'}, valid_session
    assigns[:exfec].should == @exf 
  end
  
  
  
end