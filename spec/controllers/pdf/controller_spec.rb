# coding: utf-8 

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Pdf::Controller do
  
  class Pdf::ControllerTest
    include Pdf::Controller
  end
  
  describe 'set_request_path' do
    
    subject {Pdf::ControllerTest.new}
    
    it 'retire produce_pdf et ce qui suit et retourne l url sans les options' do
      subject.stub_chain(:request, :url).and_return 'http://bonjour/test/produce_pdf?une_option'
      subject.send(:set_request_path).should == 'http://bonjour/test'
    end
    
    it 'sans options' do
      subject.stub_chain(:request, :url).and_return 'http://bonjour/test/produce_pdf'
      subject.send(:set_request_path).should == 'http://bonjour/test'
    end
    
    
  end
  
end
