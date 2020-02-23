require 'eventmachine'
require_relative 'currency_diff'

module Binance
  module Listener
    class Run
      def call
        EM.run {
          Listener::CurrencyDiff.new(currency_pair: 'BTCUSDT').call
        }
      end
    end
  end
end

Binance::Listener::Run.new.call
