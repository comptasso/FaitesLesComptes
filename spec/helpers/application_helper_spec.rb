# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do

  let(:o) {mock_model(Organism, title:'Ma petite affaire')}

  
  describe 'header_title' do
    
    it 'sans organisme, affiche Faites Les Comptes' do
      helper.header_title.should match 'Faites les comptes'
    end

    it 'avec organisme, affiche le titre de l\'organisme' do
      assign(:organism, o)
      helper.header_title.should match 'Ma petite affaire'
    end

  end

  describe 'active_inactive' do


    it 'fait appelle à request' do
      helper.should_receive(:request).and_return(double URI, :path=>'/admin/organisms')
      helper.active_inactive('compta')
    end

    it 'si le nom n est pas celui demandé, est inactive' do
      helper.stub(:request).and_return(double URI, :path=>'/admin/organisms')
      helper.active_inactive('compta').should == 'inactive'
    end

    it 'actif dans le cas contraire' do
      helper.stub(:request).and_return(double URI, :path=>'/admin/organisms')
      helper.active_inactive('admin').should == 'active'
    end

    it 's il n y a pas de prefis, l espace est main' do
      helper.stub(:request).and_return(double URI, :path=>'/organisms')
      helper.active_inactive('main').should == 'active'
      helper.active_inactive('compta').should == 'inactive'
    end
  end
end

