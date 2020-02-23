# frozen_string_literal: true

require_relative '../../../store/store'

# Query Object for symbol store
class SymbolQuery
  attr_accessor :initial_scope

  def initialize(options = {})
    @store = options[:store] || Binance::Store.new
    @initial_scope = {}
  end

  def call(params)
    initial_scope['lastUpdateId'] = update_info(params)['u']
    initial_scope['bids'] = bids_lots(params)
    initial_scope['asks'] = asks_lots(params)
    initial_scope
  end

  private

  def update_info(params)
    @store.select_all_from("#{params['symbol']}_info") || []
  end

  def bids_lots(params)
    sort_symbols('bids', params).reverse.first(params['limit'].to_i)
  end

  def asks_lots(params)
    sort_symbols('asks', params).first(params['limit'].to_i)
  end

  def sort_symbols(sym_type, params)
    all_lots(sym_type, params)
      .tap { |lots| return [] unless lots }
      .map { |i| [i[0].to_f, i[1]] }
      .sort
  end

  def all_lots(lot_type, params)
    @store.select_all_from("#{params['symbol']}_#{lot_type}")
  end
end
