# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')


describe 'compta/results/show' do 
  include JcCapybara


 
  it 'should render' do
    render
  end
  context 'rendre la page' do
    before(:each) do
      render
    end

    it 'affiche le titre Compte de résultats' do
      page.find('h3').should have_content('Compte de résultats')
    end

    it 'affiche une table résultat d exploitation' do
      pending 'en attente de faire le mapping accounts vers l édition du compte de résultats'
      page.all('table#exploitation').should have(1).element
    end
  end
end
