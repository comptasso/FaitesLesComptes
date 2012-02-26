# coding: utf-8

class CheckDeposit < ActiveRecord::Base
  has_many :lines
  belongs_to :bank_account
  has_one :bank_extract_line

  attr_reader :picked_checks

  after_initialize :create_picked_checks
  after_save :update_lines
  

  validates :bank_account, :presence=>true

  before_validation :check_if_list_line_empty
  # list_lines ne doit pas être vide
  before_destroy :remove_check_deposit_id_in_lines


  def total
    lines.sum(:credit)
  end

  # TODO voir si on garde cette partie avec les @picked_checks.
  # le problème est que tant que check_deposit n'est pas sauvé les associations lines ne sont
  # pas totalement opérationnelles. On pourrait choisir de sauver d'emblée le check_deposit pour se simplifier la vie.

  def total_picked_checks
    @picked_checks.sum {|c| c.credit}
  end

  def remove_picked_check(line)
    @picked_checks.delete_if {|c| c == line}
  end

  # remove check retire un chèque qui est DEJA associé à la remise de chèque
  # ce qui veut dire qu'elle a déja été sauvée
  def remove_check(line)
    line.update_attribute(:check_deposit, nil)
  end

  def pick_check(line)
    @picked_checks << line
  end

  def pick_all_checks
    @picked_checks=Line.non_depose.all
  end

  private

  def remove_check_deposit_id_in_lines
    puts 'dans le callback'
    lines.delete(lines)
  end

  def update_lines
    @picked_checks.each {|l| l.update_attribute(:check_deposit_id, id); l.save} if @picked_checks
  end

  def check_if_list_line_empty
    self.errors[:base] <<  'Il doit y avoir au moins un chèque dans une remise' unless @picked_checks && !@picked_checks.empty?
  end

  def create_picked_checks
    @picked_checks=[]
  end
end
