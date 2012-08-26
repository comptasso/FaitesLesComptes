#coding: utf-8

require 'spec_helper'

describe "sessions/new" do
  let(:cu) {mock_model(User, :name=>'quidam')}

  before(:each) do
    assign(:user, cu)
    render
  end

  it 'indique Connexion' do
    assert_select 'h3', 'Connexion'
  end

  it 'affiche un formulaire' do
    assert_select 'form' do
      assert_select "input[type='text']", 1
    end
  end

  it 'avec un bouton Entrée' do
    assert_select('form') do
      assert_select "input[type='submit']", 1
    end
  end
end
