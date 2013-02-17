# -*- encoding : utf-8 -*-

module CashControlsHelper

  def cash_difference(cash_control)
    delta= cash_control.difference.abs
    if ( delta> 0.001)
      "Attention, il subsite un écart de caisse de #{two_decimals(delta)}"
    else
      ''
    end
  end

  

end
