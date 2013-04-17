# coding: utf-8

require 'spec_helper'

describe 'bienvenue' do
  it 'connait l environnement ocra (utilisé pour Windows)' do
    Rails.stub(:env).and_return('ocra')
  end
end
