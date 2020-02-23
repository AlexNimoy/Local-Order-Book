require_relative '../../store/store'
require_relative 'receive'

module Binance
  module Listener
    module Snapshot
      class CreateTask
        def initialize(config)
          @api_url = config[:api_url]
          @currency_pair = config[:currency_pair]
          @store = config[:store] || ::Binance::Store.new 
          @snapshot = config[:snapshot]|| Snapshot::Receive.new(@api_url)
        end

        def call 
          snapshot = JSON.parse(@snapshot.call)
          @store.queue_work(snapshot.merge(s: @currency_pair).to_json)
        end
      end
    end
  end
end

