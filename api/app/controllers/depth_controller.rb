# frozen_string_literal: true

require_relative 'base_controller'
require_relative '../queries/symbol_query'

# Currency controller
class DepthController < BaseController
  def show
    permitted = params.slice('symbol', 'limit')
    result = SymbolQuery.new.call(permitted)
    success_response(result)
  end
end
