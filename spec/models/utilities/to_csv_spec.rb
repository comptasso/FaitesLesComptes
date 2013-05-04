# coding: utf-8

require 'spec_helper' 

  

  describe Utilities::ToCsv do

    before(:each) do
      class TestModule
         include Utilities::ToCsv
      end
      @tm = TestModule.new
    end

    it 'to_csv doit être implémenté dans les classes incluant le module' do
         expect {@tm.send(:to_csv)}.to raise_error 'Vous devez implémentez cette méthode dans la classe dans laquelle vous incluez ce module'
    end

    it 'to_xls appelle to_csv avec un encode Windows' do
      @tm.stub(:to_csv).and_return(@s = 'bonjour')
      @s.should_receive(:encode).with('windows-1252').and_return 'bonsoir'
      @tm.to_xls.should == 'bonsoir'
    end


  end
