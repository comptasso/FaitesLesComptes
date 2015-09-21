# coding: utf-8

require 'spec_helper'

RSpec.configure do |config|
#  config.filter = {wip:true}
end

include OrganismFixtureBis

describe "Cashes" do

 before(:each) do
    use_test_user
    use_test_organism
    login_as(@cu, 'MonkeyMocha')
  end


  describe "GET /cash_cash_lines" do

    it 'dispose bien d un organisme', wip:true do
      puts @o.inspect
      puts @cu.organisms.count
      puts Holder.count
      @o.should be_an_instance_of(Organism)
    end

    it "without a month params do a redirect" do
      visit cash_cash_lines_path(@c)
      page.should have_content "Exercice #{Date.today.year}"
      page.find('h3 li.active').should have_content(I18n.l(Date.today,format:'%b'))
    end
  end
end
