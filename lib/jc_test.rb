# coding: utf-8

@o=Organism.first
puts @o
@b=@o.bank_accounts.first
puts @b
@cd=@b.check_deposits.new(:deposit_date=>Date.today)
puts @cd
@cd.define_organism(@o)
puts CheckDeposit.bids