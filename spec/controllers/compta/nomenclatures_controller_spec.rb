# coding: utf-8

require 'spec_helper'
require 'support/spec_controller_helper'

describe Compta::NomenclaturesController do
  include SpecControllerHelper

  before(:each) do
    minimal_instances
    @p.stub(:all_natures_linked_to_account?).and_return true
  end

  describe 'GET show' do

    it 'crée une sheet et l assigne' do
      @o.should_receive(:nomenclature).and_return(@ar = double(Arel))
      @ar.should_receive(:folios).and_return @ar
      @ar.should_receive(:order). and_return [1,2,3]
      get :show, {}, valid_session
      assigns(:folios).should == [1,2,3]
    end




  end




end

