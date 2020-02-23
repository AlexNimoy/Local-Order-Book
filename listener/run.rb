# frozen_string_literal: true

require 'eventmachine'
require_relative 'currency_diff'

module Binance
  module Listener
    # Run WS listener
    class Run
      def call
        EM.run do
          Listener::CurrencyDiff.new(currency_pair: 'BTCUSDT').call
        end
      end
    end
  end
end

Binance::Listener::Run.new.call
