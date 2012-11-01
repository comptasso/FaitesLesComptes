require 'spec_helper'

describe Compta::GeneralLedgersController do
  include SpecControllerHelper

  before(:each) do
    minimal_instances
    @p.stub(:all_natures_linked_to_account?).and_return true
  end

  

  describe "GET 'new'" do
    it "returns http success" do
      Compta::PdfGeneralLedger.should_receive(:new).with(@p).and_return(@pdf = double(Compta::PdfGeneralLedger))
      @pdf.should_receive(:render).with("lib/pdf_document/prawn_files/general_ledger.pdf.prawn").and_return 'bonjour'
      get 'new', {period_id:@p.to_param, format:'pdf'}, valid_session
      response.should be_success
    end
  end

end
