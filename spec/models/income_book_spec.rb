# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IncomeBook do
  include OrganismFixture


  describe 'test de pending checks' do
    before(:each) do
      create_minimal_organism
      @rem_acc = Account.create!(title:'Remise chèque', period_id:@p.id, number:'520')
      @l1 = @ib.lines.create!(line_date: Date.today,:narration=>'ligne de test', credit: 44, payment_mode:'Chèque', nature_id:@rec.id)
#      @l1.valid?
#      puts @l1.errors.messages
      @l2 = @ib.lines.create!(line_date: Date.today, :narration=>'ligne de test',credit: 101, payment_mode:'Chèque', nature: @rec)
      @l3 = @ib.lines.create!(line_date: Date.today, :narration=>'ligne de test', credit: 300, payment_mode:'Chèque', nature: @rec)
      @l5 = @ib.lines.create!(line_date: Date.today, counter_account_id:@baca.id,:narration=>'ligne de test',credit: 50000, payment_mode:'Virement', nature: @rec)
    end
  

    it "verif des données" do
      @ib.should be_an_instance_of(IncomeBook)
    end

    it "pending_checks should return 3 checks" do
      @ib.pending_checks.count.should == 3
    end

    context "quand on fait une remise totale" do
      it "ne reste plus de pending checks" do
        @cd=@ba.check_deposits.new(deposit_date: Date.today)
        @cd.pick_all_checks
        @cd.save!
        @ib.pending_checks.count.should == 0
      end
    end

    context "quand on fait une remise partielle" do
      it "reste des pending checks" do
        @cd=@ba.check_deposits.new(deposit_date: Date.today)
        @cd.checks <<  @ib.pending_checks.first
        @cd.save!
        @ib.pending_checks.count.should == 2
      end
    end

  end
end

