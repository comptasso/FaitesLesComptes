# -*- encoding : utf-8 -*-
require 'change_period'


class PeriodsController < ApplicationController

  logger.debug 'dans PeriodsController'
  include ChangePeriod

end
