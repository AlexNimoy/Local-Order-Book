# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../../api/app/queries/symbol_query'

RSpec.describe SymbolQuery do
  let(:params) { { 'symbol' => 'BTCUSDT', 'limit' => '1' } }

  class self::TestStore
    attr_accessor :info, :bids, :asks

    def select_all_from(params)
      case params
      when 'BTCUSDT_info'
        info
      when 'BTCUSDT_bids'
        bids
      when 'BTCUSDT_asks'
        asks
      end
    end
  end

  context 'return data' do
    let(:info) { { 'u' => '100500' } }
    let(:bids) { { '999.01' => '0.0123', '998.01' => '0.0124' } }
    let(:asks) { { '997.01' => '0.0125', '996.01' => '0.0126' } }

    let(:test_store) do
      store = self.class::TestStore.new
      store.info = info
      store.bids = bids
      store.asks = asks
      store
    end

    let(:store_request) { described_class.new(store: test_store).call(params) }

    it 'response contents keys' do
      expect(store_request.keys).to include('lastUpdateId', 'bids', 'asks')
    end

    it 'return lastUpdateId' do
      expect(store_request['lastUpdateId']).to eq('100500')
    end

    it 'return bids eq limit' do
      expect(store_request['bids'].length).to eq(1)
    end

    it 'returned bids is correct' do
      expect(store_request['bids']).to eq([[999.01, '0.0123']])
    end

    it 'return asks eq limit' do
      expect(store_request['asks'].length).to eq(1)
    end

    it 'returned asks is correct' do
      expect(store_request['asks']).to eq([[996.01, '0.0126']])
    end
  end
end
