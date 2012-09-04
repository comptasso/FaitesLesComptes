# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IncomeBook do
#  before(:each) do
#    @income_book = IncomeBook.new
#  end

  describe 'test de pending checks' do
    before(:each) do
    @o=Organism.create!(title: 'test check_deposit', database_name:'assotest1')
    @p=@o.periods.create!(start_date: Date.today.beginning_of_year, close_date: Date.today.end_of_year)
    @ba=@o.bank_accounts.create!(name: 'IBAN', number: '123456Z')
    @baca=@ba.current_account(@p)
    @b=@o.income_books.create!(title: 'Recettes')
    @n=@p.natures.create!(name: 'ventes')
    @l1=@b.lines.create!(line_date: Date.today,counter_account_id:@baca.id,:narration=>'ligne de test', credit: 44, payment_mode:'Chèque', nature: @n)
    @l2=@b.lines.create!(line_date: Date.today,counter_account_id:@baca.id, :narration=>'ligne de test',credit: 101, payment_mode:'Chèque', nature: @n)
    @l3=@b.lines.create!(line_date: Date.today,counter_account_id:@baca.id,:narration=>'ligne de test', credit: 300, payment_mode:'Chèque', nature: @n)
    @l5=@b.lines.create!(line_date: Date.today, counter_account_id:@baca.id,:narration=>'ligne de test',credit: 50000, payment_mode:'Virement', nature: @n)
    end
  

  it "verif des données" do
    @b.should be_an_instance_of(IncomeBook)
  end

  it "pending_checks should return 3 checks" do
    @b.pending_checks.count.should == 3 
  end

  context "quand on fait une remise totale" do
    it "ne reste plus de pending checks" do
      @cd=@ba.check_deposits.new(deposit_date: Date.today)
      @cd.pick_all_checks
      @cd.save!
      @b.pending_checks.count.should == 0
    end
  end

    context "quand on fait une remise partielle" do
       it "reste des pending checks" do
          @cd=@ba.check_deposits.new(deposit_date: Date.today)
          @cd.checks <<  @b.pending_checks.first
          @cd.save!
          @b.pending_checks.count.should == 2
    end
    end

    end
end

